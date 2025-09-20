import Core
import XCTest
@testable import Root
@testable import Billslist

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

@MainActor
final class BillslistStoreTests: XCTestCase {

    func testLedgerResponseUpdatesVisibleLedgerAndBills() {
        let owner = User(id: "owner", name: "Owner")
        let initialLedger = AccountBook(
            owner: owner,
            participacer: [],
            bills: [],
            id: "ledger-1",
            name: "Personal",
            createdAt: ""
        )

        var state = BillslistStore.State(
            bills: [],
            ledger: initialLedger
        )

        let newerBill = Bill(
            id: "bill-newer",
            value: 20,
            type: .income,
            mainCategory: BillMainCategory(id: "main", name: "Main", subCategories: []),
            subCategory: BillSubCategory(id: "sub", name: "Sub"),
            createdAt: "2024-01-02T00:00:00Z",
            updatedAt: "2024-01-02T12:00:00Z",
            createdByUser: owner,
            updatedByUser: owner,
            description: "New income"
        )

        let olderBill = Bill(
            id: "bill-older",
            value: 10,
            type: .payment,
            mainCategory: BillMainCategory(id: "main", name: "Main", subCategories: []),
            subCategory: BillSubCategory(id: "sub", name: "Sub"),
            createdAt: "2024-01-01T00:00:00Z",
            updatedAt: "2024-01-01T08:00:00Z",
            createdByUser: owner,
            updatedByUser: owner,
            description: "Groceries"
        )

        let refreshedLedger = AccountBook(
            owner: owner,
            participacer: [],
            bills: [olderBill, newerBill],
            id: "ledger-1",
            name: "Personal",
            createdAt: ""
        )

        _ = BillslistStore().reduce(into: &state, action: .ledgersResponse([refreshedLedger]))

        XCTAssertEqual(state.ledger, refreshedLedger)
        XCTAssertEqual(
            state.bills,
            [BillSectionData(id: refreshedLedger.id, header: refreshedLedger.name, cells: [newerBill, olderBill])]
        )
    }
}
