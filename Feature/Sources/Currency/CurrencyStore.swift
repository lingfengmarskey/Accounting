//
//  CurrencyStore.swift
//  
//
//  Created by Marcos Meng on 2024/01/24.
//

import Foundation
import ComposableArchitecture
import Domain
import Core
@Reducer
public struct CurrencyStore {
    @ObservableState
    public struct State {
        var currencies: [CurrencyModel]
        var selectedCurrency: CurrencyModel?
        var isLoading: Bool

        @Presents var alert: AlertState<Action.Alert>?

        public init(currencies: [CurrencyModel] = [],
                    selectedCurrency: CurrencyModel? = nil,
                    isLoading: Bool = false
        ) {
            self.currencies = currencies
            self.selectedCurrency = selectedCurrency
            self.isLoading = isLoading
        }
    }

    public enum Action {
        case onAppear
        case onTap(CurrencyModel)
        case localCurrenciesResponse([CurrencyModel])
        case syncResponse(TaskResult<[CurrencyModel]>)
        case alert(PresentationAction<Alert>)

        public enum Alert: Equatable {
            case dismiss
        }
    }

    public init() {}

    @Dependency(\.currencyClient) var currencyClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            func applyCurrencies(_ currencies: [CurrencyModel]) {
                state.currencies = currencies
                if let selected = state.selectedCurrency,
                   let matched = currencies.first(where: { $0.recordName == selected.recordName }) {
                    state.selectedCurrency = matched
                } else if state.selectedCurrency == nil {
                    state.selectedCurrency = currencies.first
                }
            }

            switch action {
            case .onAppear:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                return .run { send in
                    let local = await currencyClient.fetchLocalCurrencies()
                    await send(.localCurrenciesResponse(local))

                    do {
                        let remote = try await currencyClient.syncFromCloud()
                        await send(.syncResponse(.success(remote)))
                    } catch {
                        await send(.syncResponse(.failure(error)))
                    }
                }
            case let .localCurrenciesResponse(currencies):
                applyCurrencies(currencies)
                return .none
            case let .syncResponse(.success(currencies)):
                state.isLoading = false
                applyCurrencies(currencies)
                return .none
            case let .syncResponse(.failure(error)):
                state.isLoading = false
                state.alert = AlertState {
                    TextState("同步失败")
                } actions: {
                    ButtonState(action: .send(.dismiss)) {
                        TextState("确定")
                    }
                } message: {
                    TextState(error.localizedDescription)
                }
                return .none
            case let .onTap(value):
                state.selectedCurrency = value
                return .none
            case .alert(.dismiss):
                state.alert = nil
                return .none
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
