import Core
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

    func testNavigateToBillsListAfterSavingFirstLedger() {
        let savedLedger = AccountBook(
            owner: .init(id: "owner-id", name: "Owner"),
            participacer: [],
            bills: [],
            id: "ledger-id",
            name: "My Ledger",
            createdAt: "2024-02-09T12:00:00Z"
        )

        var state = RootStore.State(
            ledgers: [],
            destination: .addBook(AccountBookConfigStore.State(book: savedLedger))
        )

        _ = RootStore().reduce(into: &state, action: .destination(.presented(.addBook(.onSaved))))

        XCTAssertEqual(state.ledgers, [savedLedger])
        XCTAssertEqual(state.bills.ledger, savedLedger)
        XCTAssertTrue(state.bills.bills.isEmpty)

        switch state.destination {
        case let .billslist(billsState):
            XCTAssertEqual(billsState.ledger, savedLedger)
        default:
            XCTFail("Expected bills list destination after saving ledger")
        }
    }
}
