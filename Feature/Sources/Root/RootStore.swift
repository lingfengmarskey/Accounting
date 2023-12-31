//
//  RootStore.swift
//  
//
//  Created by Marcos Meng on 2023/08/31.
//

import Foundation
import ComposableArchitecture
import AccountBookList

public struct RootStore: Reducer {
    public struct State: Equatable {
        public var accountBooklistState = AccountBooklistStore.State()

        public init(accountBooklistState: AccountBooklistStore.State = .init()) {
            self.accountBooklistState = accountBooklistState
        }
    }

    public enum Action: Equatable {
        case onAppear
        case accountBooklistAction(AccountBooklistStore.Action)
    }

    public init(){}
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.accountBooklistState, action: /Action.accountBooklistAction) {
            AccountBooklistStore()
        }
    }
    
}
