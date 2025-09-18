//
//  BillslistStore.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import BillDetail
import ComposableArchitecture
import Core
import Domain
import Foundation
import InputAccounts
import Setting

@Reducer
public struct BillslistStore {
    @ObservableState
    public struct State{
        var bills: [BillSectionData] = .stub()
        var ledger: AccountBook
        @Presents var destination: Destination.State?

        public init(
            bills: [BillSectionData],
            ledger: AccountBook,
            destination: Destination.State? = nil
        ) {
            self.bills = bills
            self.ledger = ledger
            self.destination = destination
        }
        
        public static var none = State.init(bills: [], ledger: .none)
    }

    public enum Action {
        case onAppear
        case tapSetting
        case tapAdd(BillType?)
        case onTap(Bill)
        case ledgersResponse([AccountBook])
        case destination(PresentationAction<Destination.Action>)
    }

    public init() {}

    @Dependency(\.ledgerClient) var ledgerClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let ledgers = await ledgerClient.fetchLedgers()
                    await send(.ledgersResponse(ledgers))
                }
            case let .onTap(bill):
                state.destination = .billDetail(.init(billModel: bill))
                return .none
            case .tapSetting:
                state.destination = .setting(.init())
                return .none
            case .tapAdd(nil):
                state.destination = .addAccounts(.init(ledger: state.ledger))
                return .none
            case .tapAdd(let type?):
                state.destination = .addAccounts(
                    .init(
                        title: type == .income ? "Income" : "Payment",
                        selectedBillType: type,
                        ledger: state.ledger
                    )
                )
                return .none
            case let .destination(.presented(.setting(.delegate(.didSelectLedger(ledger))))):
                state.ledger = ledger
                state.bills = Self.makeBillSections(from: ledger)
                return .none
            case .destination(.presented(.addAccounts(.saveResponse(.success)))):
                // Saving has completed successfully inside InputAccountsStore.
                // Dismiss and refresh ledgers/bills.
                state.destination = nil
                return .run { send in
                    let ledgers = await ledgerClient.fetchLedgers()
                    await send(.ledgersResponse(ledgers))
                }
            case .destination(.dismiss):
                state.destination = nil
                return .none
            case .ledgersResponse(let ledgers):
                guard !ledgers.isEmpty else {
                    state.bills = []
                    return .none
                }
                if let matched = ledgers.first(where: { $0.id == state.ledger.id }) {
                    state.ledger = matched
                } else if let first = ledgers.first {
                    state.ledger = first
                }
                state.bills = Self.makeBillSections(from: state.ledger)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    @Reducer
    public enum Destination {
        case billDetail(BillDetailStore)
        case setting(SettingStore)
        case addAccounts(InputAccountsStore)
    }

}

private extension BillslistStore {
    static func makeBillSections(from ledger: AccountBook) -> [BillSectionData] {
        guard !ledger.bills.isEmpty else { return [] }
        return [
            BillSectionData(
                id: ledger.id,
                header: ledger.name,
                cells: ledger.bills.sorted(by: { $0.updatedAt > $1.updatedAt })
            )
        ]
    }
}

private extension AccountBook {
    static let placeholder = AccountBook(
        owner: .init(id: "", name: ""),
        participacer: [],
        bills: [],
        id: "",
        name: "",
        createdAt: ""
    )
}
