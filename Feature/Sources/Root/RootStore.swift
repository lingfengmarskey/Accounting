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
        public var bookConfig = AccountBookConfigStore.State()

        var bills: BillslistStore.State = .init()

        var ledgers: [AccountBook] = []

        @Presents var destination: Destination.State?

        public init(
            accountBookConfig: AccountBookConfigStore.State = AccountBookConfigStore.State(),
            bills: BillslistStore.State = .init(),
            ledgers: [AccountBook] = [],
            destination: Destination.State? = nil
        ) {
            self.bookConfig = accountBookConfig
            self.bills = bills
            self.ledgers = ledgers
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
        Scope(state: \.bookConfig, action: \.addBookAccount) {
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
                state.ledgers = ledgers
                if ledgers.isEmpty {
                    state.destination = .addBook(AccountBookConfigStore.State())
                } else {
                    guard let ledger = ledgers.first else {
                        state.destination = .addBook(AccountBookConfigStore.State())
                        return .none
                    }
                    let billsState = BillslistStore.State(
                        bills: Self.makeBillSections(from: ledger)
                    )
                    state.bills = billsState
                    state.destination = .billslist(billsState)
                }
                return .none
            case .addBookAccount(.onSaved):
                // 这里关闭页面，或切换到账单列表route
//                state.destination = nil
                if let book = state.bookConfig.book {
                    let billSections = Self.makeBillSections(from: book)
                    state.destination = .billslist(BillslistStore.State(bills: billSections))
                } else {
                    state.destination = .billslist(BillslistStore.State(bills: []))
                }
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

private extension RootStore {
    static func makeBillSections(from ledger: AccountBook) -> [BillSectionData] {
        guard !ledger.bills.isEmpty else { return [] }
        return [
            BillSectionData(
                id: ledger.id,
                header: ledger.name,
                cells: ledger.bills
            )
        ]
    }
}

