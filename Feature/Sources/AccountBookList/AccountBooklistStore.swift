//
//  ViewModel.swift
//
//
//  Created by Marcos Meng on 2022/08/04.
//

import AccountBookConfig
import ComposableArchitecture
import Core
import Foundation

public struct AccountBooklistStore: Reducer {
    public struct State: Equatable {
        var books: [AccountBookModel] = .stub()
        var saveDisable: Bool = true
        @BindingState var selected: String?

        var accountBookConfig: AccountBookConfigStore.State = .init()

        var isShouldPresent = false
        
        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case onAppear
        case toTop
        case addBook
        case selectDone
        case tapDetail(bookID: String)
        case setPresent(Bool)
        case removeItem(IndexSet)
        case binding(BindingAction<State>)
        case accountBookConfig(AccountBookConfigStore.Action)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .addBook:
                state.accountBookConfig = .init()
                return .run { send in
                    await send(.setPresent(true))
                }
            case .tapDetail(bookID: let id):
                if let book = state.books.first(where: { $0.id == id })
                {
                    state.accountBookConfig.book = book
                    return .run { send in
                        await send(.setPresent(true))
                    }
                }
                return .none
            case .setPresent(let value):
                state.isShouldPresent = value
                return .none
            case .selectDone:
                // TODO:
                return .none
            case let .removeItem(index):
                // TODO: remove item
                state.selected = nil
                state.saveDisable = true
                state.books.remove(atOffsets: index)
                return .none
            case .binding(\.$selected):
                state.saveDisable = state.selected == nil
                return .none
            case .binding:
                return .none
            case .accountBookConfig:
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.accountBookConfig, action: /Action.accountBookConfig) {
            AccountBookConfigStore()
        }
//        .ifLet(\.accountBookConfig, action: /Action.accountBookConfig) {
//            AccountBookConfigStore()
//        }
    }
}
