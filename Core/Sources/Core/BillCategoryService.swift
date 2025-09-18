import Foundation

#if canImport(CloudKit)
import CloudKit

public enum BillCategoryServiceError: Error {
    case unknown
    case cloudKit(Error)
}

extension BillCategoryServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "发生未知错误"
        case let .cloudKit(error):
            return error.localizedDescription
        }
    }
}

public final class BillCategoryService {
    private enum RecordType {
        static let mainCategory = "BillMainCategory"
        static let subCategory = "BillSubCategory"
    }

    private enum Field {
        static let name = "name"
        static let mainCategoryReference = "mainCategory"
        static let mainCategoryIdentifier = "mainCategoryId"
    }

    private let container: CKContainer
    private let publicDatabase: CKDatabase
    private let privateDatabase: CKDatabase

    public init(container: CKContainer = CKContainer(identifier: Config.containerIdentifier)) {
        self.container = container
        self.publicDatabase = container.publicCloudDatabase
        self.privateDatabase = container.privateCloudDatabase
    }

    // MARK: - Fetch

    /// Fetches all bill categories from the public database.
    /// - Returns: A list of main categories containing their associated sub categories.
    public func fetchPublicCategories() async throws -> [BillMainCategoryModel] {
        try await fetchCategories(in: publicDatabase, scope: .public)
    }

    /// Fetches all bill categories from the user's private database.
    public func fetchPrivateCategories() async throws -> [BillMainCategoryModel] {
        try await fetchCategories(in: privateDatabase, scope: .private)
    }

    /// Fetches categories from both public and private databases.
    public func fetchAllCategories() async throws -> [BillMainCategoryModel] {
        async let publicCategories = fetchPublicCategories()
        async let privateCategories = fetchPrivateCategories()
        return try await publicCategories + privateCategories
    }

    // MARK: - Create

    /// Creates a new private main category.
    @discardableResult
    public func createPrivateMainCategory(name: String) async throws -> BillMainCategoryModel {
        let record = CKRecord(recordType: RecordType.mainCategory)
        record[Field.name] = name as NSString

        let savedRecord = try await save(record: record, in: privateDatabase)
        return BillMainCategoryModel(
            id: savedRecord.recordID.recordName,
            name: name,
            subCategories: [],
            scope: .private
        )
    }

    /// Creates a new private sub category for the provided main category.
    @discardableResult
    public func createPrivateSubCategory(name: String, mainCategoryID: String) async throws -> BillSubCategoryModel {
        let record = CKRecord(recordType: RecordType.subCategory)
        record[Field.name] = name as NSString
        record[Field.mainCategoryIdentifier] = mainCategoryID as NSString

        let savedRecord = try await save(record: record, in: privateDatabase)
        return BillSubCategoryModel(
            id: savedRecord.recordID.recordName,
            name: name,
            mainCategoryID: mainCategoryID,
            scope: .private
        )
    }

    // MARK: - Helpers

    private func fetchCategories(in database: CKDatabase, scope: BillCategoryScope) async throws -> [BillMainCategoryModel] {
        let mainRecords = try await fetchRecords(in: database, recordType: RecordType.mainCategory)
        let subRecords = try await fetchRecords(in: database, recordType: RecordType.subCategory)

        let subModels = subRecords.map { record -> BillSubCategoryModel in
            let mainCategoryIdentifier: String?

            if let reference = record[Field.mainCategoryReference] as? CKRecord.Reference {
                mainCategoryIdentifier = reference.recordID.recordName
            } else if let identifier = record[Field.mainCategoryIdentifier] as? String {
                mainCategoryIdentifier = identifier
            } else {
                mainCategoryIdentifier = nil
            }

            let name = (record[Field.name] as? String) ?? ""
            return BillSubCategoryModel(
                id: record.recordID.recordName,
                name: name,
                mainCategoryID: mainCategoryIdentifier,
                scope: scope
            )
        }

        let subCategoryDictionary = Dictionary(grouping: subModels, by: { $0.mainCategoryID ?? "" })

        return mainRecords.map { record in
            let identifier = record.recordID.recordName
            let name = (record[Field.name] as? String) ?? ""
            let relatedSubCategories = subCategoryDictionary[identifier] ?? []

            return BillMainCategoryModel(
                id: identifier,
                name: name,
                subCategories: relatedSubCategories,
                scope: scope
            )
        }
    }

    private func fetchRecords(in database: CKDatabase, recordType: String) async throws -> [CKRecord] {
        try await withCheckedThrowingContinuation { continuation in
            var fetchedRecords: [CKRecord] = []
            var isFinished = false

            func fetch(cursor: CKQueryOperation.Cursor?) {
                let operation: CKQueryOperation
                if let cursor = cursor {
                    operation = CKQueryOperation(cursor: cursor)
                } else {
                    let predicate = NSPredicate(value: true)
                    let query = CKQuery(recordType: recordType, predicate: predicate)
                    operation = CKQueryOperation(query: query)
                }

                operation.recordFetchedBlock = { record in
                    fetchedRecords.append(record)
                }

                operation.queryCompletionBlock = { cursor, error in
                    if isFinished {
                        return
                    }

                    if let error = error {
                        isFinished = true
                        continuation.resume(throwing: BillCategoryServiceError.cloudKit(error))
                        return
                    }

                    guard let cursor = cursor else {
                        isFinished = true
                        continuation.resume(returning: fetchedRecords)
                        return
                    }

                    fetch(cursor: cursor)
                }

                database.add(operation)
            }

            fetch(cursor: nil)
        }
    }

    private func save(record: CKRecord, in database: CKDatabase) async throws -> CKRecord {
        try await withCheckedThrowingContinuation { continuation in
            database.save(record) { savedRecord, error in
                if let error = error {
                    continuation.resume(throwing: BillCategoryServiceError.cloudKit(error))
                    return
                }

                guard let savedRecord = savedRecord else {
                    continuation.resume(throwing: BillCategoryServiceError.unknown)
                    return
                }

                continuation.resume(returning: savedRecord)
            }
        }
    }
}

#else

public enum BillCategoryServiceError: Error {
    case unavailable
}

extension BillCategoryServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unavailable:
            return "当前平台不支持账单分类服务"
        }
    }
}

public final class BillCategoryService {
    public init(container: Any? = nil) {}

    public func fetchPublicCategories() async throws -> [BillMainCategoryModel] {
        throw BillCategoryServiceError.unavailable
    }

    public func fetchPrivateCategories() async throws -> [BillMainCategoryModel] {
        throw BillCategoryServiceError.unavailable
    }

    public func fetchAllCategories() async throws -> [BillMainCategoryModel] {
        throw BillCategoryServiceError.unavailable
    }

    @discardableResult
    public func createPrivateMainCategory(name: String) async throws -> BillMainCategoryModel {
        throw BillCategoryServiceError.unavailable
    }

    @discardableResult
    public func createPrivateSubCategory(name: String, mainCategoryID: String) async throws -> BillSubCategoryModel {
        throw BillCategoryServiceError.unavailable
    }
}

#endif
