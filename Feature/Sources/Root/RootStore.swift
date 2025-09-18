//
//  RootStore.swift
//
//
//  Created by Marcos Meng on 2023/08/31.
//

import AccountBookConfig
import Billslist
import ComposableArchitecture
import Foundation
import Core


@Reducer
public struct RootStore {
    @Reducer
    public enum Destination {
        case billslist(BillslistStore)
        case addBook(AccountBookConfigStore)
    }

    @ObservableState
    public struct State {
        public var accountBooklistState = AccountBookConfigStore.State()

        var bills: BillslistStore.State = .init()

        @Presents var destination: Destination.State?

        public init(
            accountBookConfig: AccountBookConfigStore.State = AccountBookConfigStore.State(),
            bills: BillslistStore.State = .init(),
            destination: Destination.State? = nil
        ) {
            self.accountBooklistState = accountBooklistState
            self.bills = bills
            self.destination = destination
        }
    }

    public enum Action {
        case onAppear
        case addBookAccount(AccountBookConfigStore.Action)
        case bills(BillslistStore.Action)
        case ledgersLoaded([AccountBook])
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.ledgerClient) public var ledgerClient

    public init() {}

    public var body: some Reducer<State, Action> {
        Scope(state: \.accountBooklistState, action: \.addBookAccount) {
            AccountBookConfigStore()
        }
        Scope(state: \.bills, action: \.bills) {
            BillslistStore()
        }
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let ledgers = await ledgerClient.fetchLedgers()
                    await send(.ledgersLoaded(ledgers))
                }
            case .ledgersLoaded(let ledgers):
                if ledgers.isEmpty {
                    state.destination = .addBook(AccountBookConfigStore.State())
                } else {
                    // 有账本：选择一个当前账本并进入账单列表
                    // TODO
                    state.destination = .billslist(BillslistStore.State())
                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
