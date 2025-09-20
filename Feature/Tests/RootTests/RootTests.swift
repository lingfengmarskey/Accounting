import Core
import XCTest
@testable import Root

@MainActor
final class RootTests: XCTestCase {
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
