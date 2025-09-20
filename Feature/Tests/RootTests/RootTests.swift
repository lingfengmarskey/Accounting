import XCTest
import Core
@testable import Root

@MainActor
final class RootTests: XCTestCase {
    func testLoadsPreferredLedgerAfterRestart() {
        let owner = User(id: "owner", name: "Owner")
        let firstLedger = AccountBook(
            owner: owner,
            participacer: [],
            bills: [],
            id: "ledger-1",
            name: "Ledger 1",
            createdAt: ""
        )
        let secondLedger = AccountBook(
            owner: owner,
            participacer: [],
            bills: [],
            id: "ledger-2",
            name: "Ledger 2",
            createdAt: ""
        )
        let ledgers = [firstLedger, secondLedger]

        var state = RootStore.State()
        let reducer = RootStore()

        UserDefaults.standard.set(secondLedger.id, forKey: "currentBook")
        defer { UserDefaults.standard.removeObject(forKey: "currentBook") }

        _ = reducer.reduce(into: &state, action: .ledgersLoaded(ledgers))

        XCTAssertEqual(state.ledgers, ledgers)
        XCTAssertEqual(state.bills.ledger.id, secondLedger.id)
        switch state.destination {
        case .billslist(let billsState):
            XCTAssertEqual(billsState.ledger.id, secondLedger.id)
        default:
            XCTFail("Expected bills list destination to be presented")
        }
    }
}
