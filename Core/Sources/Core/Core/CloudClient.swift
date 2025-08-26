import CloudKit
import ComposableArchitecture
import Combine

enum Config {
    /// iCloud container identifier.
    /// Update this if you wish to use your own iCloud container.
    static let containerIdentifier = "iCloud.com.marcos.meng.tests.cloudkit.sharing"
    
    /// Account Book zone name
    static let bookZone = CKRecordZone(zoneName: "AccountBooks")
    
    static let container = "RecordBookData"
}


protocol ResponseDataProtocol: Codable {

}


public enum CloudError: Error {
    case notFound
    case unknow(String?)
}

public class CloudClient {
    public let shared = CloudClient()
    func test() {
        CKContainer.default().requestApplicationPermission(.userDiscoverability) { (status, error) in
            CKContainer.default().fetchUserRecordID { (record, error) in
                CKContainer.default().discoverUserIdentity(withUserRecordID: record!, completionHandler: { (userID, error) in
                    print("====" + (userID?.hasiCloudAccount.description ?? ""))
                    print("====" + (userID?.lookupInfo?.phoneNumber ?? ""))
                    print("====" + (userID?.lookupInfo?.emailAddress ?? ""))
                    print("====" + (userID?.nameComponents?.givenName)! + " " + (userID?.nameComponents?.familyName)!)
                })
            }
        }
    }
    
}
