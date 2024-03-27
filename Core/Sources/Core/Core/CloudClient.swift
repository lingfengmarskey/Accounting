import CloudKit
import ComposableArchitecture
import Combine

enum Config {
    /// iCloud container identifier.
    /// Update this if you wish to use your own iCloud container.
    static let containerIdentifier = "iCloud.com.marcos.meng.tests.cloudkit.sharing"
    
    /// Account Book zone name
    static let bookZone = CKRecordZone(zoneName: "AccountBooks")
}


protocol ResponseDataProtocol: Codable {

}

//protocol FetchProtocol {
//    associatedtype model = ResponseDataProtocol
//    var parames: [String: Any] { get }
//}
//
//protocol CloudAPIProtocol {
//    func fetch<T: FetchProtocol>(info: T) async ->  Result<T.model, Error>
//}

public enum CloudError: Error {
    case notFound
    case unknow(String?)
}

public class CloudClient {
//    public var getBook: (_ id: String) -> Effect<AccountBookModel, CloudError>
//    
//    lazy var container = CKContainer(identifier: Config.containerIdentifier)
//    
//    /// This project uses the user's private database.
//    private lazy var database = container.privateCloudDatabase
//    
//    public init(
//        getBook: @escaping (_ id: String) -> Effect<AccountBookModel, CloudError>
//    ) {
//        self.getBook = getBook
//    }
//
//    /// Creates the Book zone in use if needed.
//    private func createBookZoneIfNeeded() async throws {
//        // Avoid the operation if this has already been done.
//        guard !UserDefaults.standard.bool(forKey: "isBookZoneCreated") else {
//            return
//        }
//
//        do {
//            _ = try await database.modifyRecordZones(saving: [Config.bookZone], deleting: [])
//        } catch {
//            print("ERROR: Failed to create custom zone: \(error.localizedDescription)")
//            throw error
//        }
//
//        UserDefaults.standard.setValue(true, forKey: "isBookZoneCreated")
//    }
        
    func test() {
        
    }
    
//    public static let live = CloudClient(
//        getBook: { id in
////            let recordId = CKRecord.ID.init(recordName: "")
////            container.privateCloudDatabase.fetch(withRecordID: recordId) { record, error in
////                if let error = error {
////                    print("record fetch failure, error is \(error.localizedDescription)")
////                } else {
////                    print("record fetch success, record is \(record)")
////                }
////            }
//            
//            Effect<AccountBook, CloudError>.run { subscriber in
////                GraphQLClient.client.fetch(query: query) { result in
////                    switch result {
////                    case .success(let graphQLResult):
////                        if let data = graphQLResult.data {
////                            subscriber.send(data)
////                            subscriber.send(completion: .finished)
////                        } else if let error = graphQLResult.errors?.first {
////                            subscriber.send(completion: .failure(ApiError(error: error)))
////                        } else {
////                            // TODO
////                        }
////                    case .failure(let error):
////                       \
////                subscriber.send(completion: .failure(ApiError(error: error)))
////                    }
////                }
//                let recordId = CKRecord.ID.init(recordName: "")
//                container.privateCloudDatabase.fetch(withRecordID: recordId) { record, error in
//                    if let error = error {
////                        print("record fetch failure, error is \(error.localizedDescription)")
//                        subscriber.send(completion: .failure(ApiError(error: error)))
//                    } else {
//                        print("record fetch success, record is \(record)")
//                    }
//                            }
//                return AnyCancellable {}
//            }
//            
//            return Effect(value: AccountBook.init(id: "", name: "", createdAt: Date()))
//        })
    
}
