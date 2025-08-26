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
import Core


@Reducer
public struct RootStore {
    @Reducer
    public enum Destination {
        case billslist(BillslistStore)
        case booklist(AccountBooklistStore)
    }

    @ObservableState
    public struct State {
        public var accountBooklistState = AccountBooklistStore.State()

        var bills: BillslistStore.State = .init()

        @Presents var destination: Destination.State?

        public init(
            accountBooklistState: AccountBooklistStore.State = AccountBooklistStore.State(),
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
        case accountBooklistAction(AccountBooklistStore.Action)
        case bills(BillslistStore.Action)
        case ledgersLoaded([AccountBook])
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(\.ledgerClient) public var ledgerClient

    public init() {}

    public var body: some Reducer<State, Action> {
        Scope(state: \.accountBooklistState, action: \.accountBooklistAction) {
            AccountBooklistStore()
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
                    // 账本为 0：跳到创建/选择账本页
                    state.destination = .booklist(AccountBooklistStore.State())
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
