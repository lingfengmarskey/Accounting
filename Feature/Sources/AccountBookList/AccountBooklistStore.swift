//
//  ViewModel.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//

import Foundation
import ComposableArchitecture
import Core
import AccountBookConfig

public struct AccountBooklistStore: Reducer {
    
    public struct State: Equatable {
        
        var books: [AccountBookModel] = .stub()
        var saveDisable: Bool = true
        @BindingState var selected: String?

        var accountBookConfig: AccountBookConfigStore.State = .init()

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case onAppear
        case toTop
        case addBook
        case selectDone
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
                // TODO: move to addBook
                state.accountBookConfig = .init()
                return .none
            case .selectDone:
                if let selected = state.selected,
                   let book = state.books.first(where: { $0.id == selected }) {
                    state.accountBookConfig.book = book
                }
                return .none
            case .removeItem(let index):
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
