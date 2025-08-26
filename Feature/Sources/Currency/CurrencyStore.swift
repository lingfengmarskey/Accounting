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

        public init(currencies: [CurrencyModel] = .stub(),
                    selectedCurrency: CurrencyModel? = nil
        ) {
            self.currencies = currencies
            self.selectedCurrency = selectedCurrency
        }
    }

    public enum Action {
        case onAppear
        case onTap(CurrencyModel)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onTap(value):
                state.selectedCurrency = value
                return .none
            }
        }
    }
}
