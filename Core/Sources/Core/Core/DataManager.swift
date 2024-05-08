//
//  DataManager.swift
//
//
//  Created by Marcos Meng on 2024/01/29.
//

import Foundation
import CoreData
import CloudKit
import UIKit

class PersistenceController {
    static let shared = PersistenceController()
    
    var documentsPath: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    lazy var managedObjectModel: NSManagedObjectModel = {
        guard let modelURL = Bundle.module.url(forResource: "RecordBookData", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to find data model")
        }
        return model
    }()

    lazy var container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "RecordBookData", managedObjectModel: managedObjectModel)

        
        let parentPath =  documentsPath
        
        // Create a store description for a local store
        let localStoreLocation = parentPath.appendingPathComponent("local.sqlite")
        let localStoreDescription =
            NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Local"
        
        // Create a store description for a CloudKit-backed local store
        let cloudStoreLocation = parentPath.appendingPathComponent("cloud.sqlite")
        let cloudStoreDescription =
            NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"


        // Set the container options on the cloud store
        cloudStoreDescription.cloudKitContainerOptions =
            NSPersistentCloudKitContainerOptions(
                containerIdentifier: "iCloud.com.marcos.meng.tests.cloudkit.sharing")
        
        // Update the container's list of store descriptions
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]

        if !checkiCloudAvailable() {
            fatalError("iCloud is not available!")
        }
        
        
//    #if DEBUG
//    do {
//        try container.initializeCloudKitSchema(options: [])
//    } catch {
//        // Handle any errors.
//        fatalError("Could not initializeCloudKitSchema. \(error)")
//    }
//    #endif
        
        // Load both stores
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError("Could not load persistent stores. \(error!)")
            }
        }
        
        return container
    }()
    
    init() {
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    
    func checkiCloudAvailable() -> Bool {
        if let _ = FileManager.default.ubiquityIdentityToken {
            // continue
            return true
        }
        else {
            // show alert
            return false
        }
    }
    
    

}

public struct DataManager {
    public static let shared = DataManager()
    
    public func createAccountBook(name: String, completion: @escaping (Error?) -> Void) {
        let context = PersistenceController.shared.container.viewContext
        let accountBook = AccountBookModel(context: context)
        accountBook.name = name
        accountBook.createdAt = Date()
        // 设置其他必要的属性...

        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func fetchAllAccountBooks() -> [AccountBookModel] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest: NSFetchRequest<AccountBookModel> = AccountBookModel.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }

    func deleteAccountBook(_ accountBook: AccountBookModel, completion: @escaping (Error?) -> Void) {
        let context = PersistenceController.shared.container.viewContext
        context.delete(accountBook)
        
        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }

    func updateAccountBook(_ accountBook: AccountBookModel, newName: String, completion: @escaping (Error?) -> Void) {
        let context = PersistenceController.shared.container.viewContext
        accountBook.name = newName
        // 更新其他属性...

        do {
            try context.save()
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

/// Data fetch from local and api
//protocol DataManagerProtocol {
//    // MARK: - Books
//    
//    func createBook(userId: String, date: Date, title: String) async throws -> Result<String, Error> // return book id
//    func removeBook(userId: String, bookId: String) async throws -> Result<String, Error> // return book id
//    func updateBook(userId: String, bookId: String, data: AccountBookModel) async throws -> Result<String, Error> // return book id
//    
//    /// fetch latest books from specific date to latest time in server
//    /// - Parameters:
//    ///   - userId: user id
//    ///   - from: last fetch date time
//    /// - Returns: books IDs
//    func fetchBooks(userId: String, from: Date) async throws -> Result<[AccountBookModel], Error>
//    
//    func invite(on bookId: String, from userId: String, to userIDs: [String]) async throws -> Result<String, Error> // return message
//    func removeMember(on bookId: String, userId: String, memberId: [String]) async throws -> Result<String, Error> // remove message
//    func fetchAllMembers(on bookId: String, userId: String) async throws -> Result<[Participacer], Error>
//    
//    func addRecord(on bookId: String, from userId: String, record: BillModel) async throws -> Result<String, Error> // return record id
//    func removeRecord(on bookId: String, from userId: String, recordId: String) async throws -> Result<String, Error>
//    func updateRecord(on bookId: String, from userId: String, record: BillModel) async throws -> Result<String, Error>
//    func fetchRecords(on bookId: String, from userId: String) async throws -> Result<[BillModel], Error>   // return record IDs
//    
//    func subscribeBookRecords(on bookId: String, from userId: String) async throws -> Result<BillModel, Error>
//
//    func subscribeBook(on bookId: String, from userId: String) async throws -> Result<[AccountBookModel], Error>
//    
//}
//
//class DataManager: DataManagerProtocol {
//    func createBook(userId: String, date: Date, title: String) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func removeBook(userId: String, bookId: String) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func updateBook(userId: String, bookId: String, data: AccountBookModel) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func fetchBooks(userId: String, from: Date) async throws -> Result<[AccountBookModel], any Error> {
//        
//    }
//    
//    func invite(on bookId: String, from userId: String, to userIDs: [String]) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func removeMember(on bookId: String, userId: String, memberId: [String]) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func fetchAllMembers(on bookId: String, userId: String) async throws -> Result<[Participacer], any Error> {
//        
//    }
//    
//    func addRecord(on bookId: String, from userId: String, record: BillModel) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func removeRecord(on bookId: String, from userId: String, recordId: String) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func updateRecord(on bookId: String, from userId: String, record: BillModel) async throws -> Result<String, any Error> {
//        
//    }
//    
//    func fetchRecords(on bookId: String, from userId: String) async throws -> Result<[BillModel], any Error> {
//        
//    }
//    
//    func subscribeBookRecords(on bookId: String, from userId: String) async throws -> Result<BillModel, any Error> {
//        
//    }
//    
//    func subscribeBook(on bookId: String, from userId: String) async throws -> Result<[AccountBookModel], any Error> {
//        
//    }
//    
//    static let shared = DataManager()
//
//    private let container: CKContainer
//    private let managedObjectContext: NSManagedObjectContext
//
//    init() {
//        
////        // Initialize CloudKit container.
////        container = CKContainer.default()
////
////        // Initialize Core Data stack.
////        let appDelegate = UIApplication.shared.delegate as! AppDelegate
////        managedObjectContext = appDelegate.persistentContainer.viewContext
//    }
//}
