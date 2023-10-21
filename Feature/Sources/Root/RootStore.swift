//
//  RootStore.swift
//
//
//  Created by Marcos Meng on 2023/08/31.
//

import AccountBookList
import Billslist
import ComposableArchitecture
import Foundation

public struct RootStore: Reducer {
    public struct State: Equatable {
        public var accountBooklistState = AccountBooklistStore.State()

        var bills: BillslistStore.State = .init()

        public init(accountBooklistState: AccountBooklistStore.State = .init()) {
            self.accountBooklistState = accountBooklistState
        }
    }

    public enum Action: Equatable {
        case onAppear
        case accountBooklistAction(AccountBooklistStore.Action)
        case bills(BillslistStore.Action)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { _, action in
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
        Scope(state: \.bills, action: /Action.bills) {
            BillslistStore()
        }
    }
}
