import Foundation

#if canImport(CloudKit)
import CloudKit
import CoreData

public enum BillCategoryServiceError: Error {
    case unknown
    case cloudKit(Error)
    case coreData(Error)
}

extension BillCategoryServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknown:
            return "发生未知错误"
        case let .cloudKit(error):
            return error.localizedDescription
        case let .coreData(error):
            return "本地数据存储失败：\(error.localizedDescription)"
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

    // MARK: - Init
    
    public static let shared = BillCategoryService()

    // 默认容器，兼容无参初始化
    public convenience init() {
        let container = CKContainer(identifier: Config.containerIdentifier)
        self.init(container: container)
    }

    public init(container: CKContainer) {
        self.container = container
        self.publicDatabase = container.publicCloudDatabase
        self.privateDatabase = container.privateCloudDatabase
    }

    // MARK: - Public API

    /// 从公共数据库拉取所有分类，并同步到本地 Core Data
    public func fetchPublicCategories() async throws -> [BillMainCategory] {
        let models = try await fetchCategoriesUsingAsyncAPI(in: publicDatabase, scope: .public)
        try await syncToCoreData(models: models, scope: .public)
        return models
    }

    /// 从私有数据库拉取所有分类，并同步到本地 Core Data
    public func fetchPrivateCategories() async throws -> [BillMainCategory] {
        let models = try await fetchCategoriesUsingAsyncAPI(in: privateDatabase, scope: .private)
        try await syncToCoreData(models: models, scope: .private)
        return models
    }

    /// 并发拉取公共与私有分类，合并后同步到 Core Data
    public func fetchAllCategories() async throws -> [BillMainCategory] {
        async let pub = fetchCategoriesUsingAsyncAPI(in: publicDatabase, scope: .public)
        async let pri = fetchCategoriesUsingAsyncAPI(in: privateDatabase, scope: .private)
        let (publicModels, privateModels) = try await (pub, pri)
        let all = publicModels + privateModels
        try await syncToCoreData(models: all, scope: nil)
        return all
    }

    // MARK: - Create (Private)

    /// 创建私有主分类（CloudKit + 本地化）
    @discardableResult
    public func createPrivateMainCategory(name: String) async throws -> BillMainCategory {
        let record = CKRecord(recordType: RecordType.mainCategory)
        record[Field.name] = name as CKRecordValue

        let savedRecord = try await privateDatabase.save(record)
        let model = BillMainCategory(
            id: savedRecord.recordID.recordName,
            name: name,
            subCategories: [],
            scope: .private
        )
        try await syncToCoreData(models: [model], scope: .private)
        return model
    }

    /// 创建私有子分类（CloudKit + 本地化）
    @discardableResult
    public func createPrivateSubCategory(name: String, mainCategoryID: String) async throws -> BillSubCategory {
        let record = CKRecord(recordType: RecordType.subCategory)
        record[Field.name] = name as CKRecordValue
        // 使用字符串字段保存父分类 ID（兼容无 Reference 的情况）
        record[Field.mainCategoryIdentifier] = mainCategoryID as CKRecordValue

        let savedRecord = try await privateDatabase.save(record)
        let sub = BillSubCategory(
            id: savedRecord.recordID.recordName,
            name: name,
            mainCategoryID: mainCategoryID,
            scope: .private
        )
        // 以占位主分类建立关系（不会覆盖已有 name）
        let main = BillMainCategory(
            id: mainCategoryID,
            name: "",
            subCategories: [sub],
            scope: .private
        )
        try await syncToCoreData(models: [main], scope: .private)
        return sub
    }

    // MARK: - Fetch helpers (CKDatabase async API)

    private func fetchCategoriesUsingAsyncAPI(in database: CKDatabase, scope: BillCategoryScope) async throws -> [BillMainCategory] {
        // 1) 主分类
        let mainQuery = CKQuery(recordType: RecordType.mainCategory, predicate: NSPredicate(value: true))
        let mainRecords = try await fetchAllRecords(using: mainQuery, in: database)

        // 2) 子分类
        let subQuery = CKQuery(recordType: RecordType.subCategory, predicate: NSPredicate(value: true))
        let subRecords = try await fetchAllRecords(using: subQuery, in: database)

        // 3) 映射为模型
        let subModels: [BillSubCategory] = subRecords.map { record in
            let parentID: String?
            if let ref = record[Field.mainCategoryReference] as? CKRecord.Reference {
                parentID = ref.recordID.recordName
            } else if let str = record[Field.mainCategoryIdentifier] as? String {
                parentID = str
            } else {
                parentID = nil
            }
            let name = (record[Field.name] as? String) ?? ""
            return BillSubCategory(
                id: record.recordID.recordName,
                name: name,
                mainCategoryID: parentID,
                scope: scope
            )
        }

        let subsByMainID = Dictionary(grouping: subModels, by: { $0.mainCategoryID ?? "" })

        let mainModels: [BillMainCategory] = mainRecords.map { record in
            let identifier = record.recordID.recordName
            let name = (record[Field.name] as? String) ?? ""
            let relatedSubCategories = subsByMainID[identifier] ?? []
            return BillMainCategory(
                id: identifier,
                name: name,
                subCategories: relatedSubCategories,
                scope: scope
            )
        }

        return mainModels
    }

    private func fetchAllRecords(using query: CKQuery, in database: CKDatabase) async throws -> [CKRecord] {
        var all: [CKRecord] = []
        var cursor: CKQueryOperation.Cursor?

        repeat {
            if let c = cursor {
                let response = try await database.records(continuingMatchFrom: c)
                try response.matchResults.forEach { _, result in
                    switch result {
                    case let .success(record):
                        all.append(record)
                    case let .failure(error):
                        throw error
                    }
                }
                cursor = response.queryCursor
            } else {
                let response = try await database.records(matching: query)
                try response.matchResults.forEach { _, result in
                    switch result {
                    case let .success(record):
                        all.append(record)
                    case let .failure(error):
                        throw error
                    }
                }
                cursor = response.queryCursor
            }
        } while cursor != nil

        return all
    }

    // MARK: - Core Data sync

    // scope == nil 表示分别处理 public/private 并清理；否则只处理指定 scope
    private func syncToCoreData(models: [BillMainCategory], scope: BillCategoryScope?) async throws {
        let container = PersistenceController.shared.container
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        try await context.perform {
            do {
                if let s = scope {
                    try self.apply(models: models.filter { $0.scope == s }, scope: s, in: context)
                } else {
                    let pub = models.filter { $0.scope == .public }
                    let pri = models.filter { $0.scope == .private }
                    try self.apply(models: pub, scope: .public, in: context)
                    try self.apply(models: pri, scope: .private, in: context)
                }

                if context.hasChanges {
                    try context.save()
                }
            } catch {
                context.reset()
                throw BillCategoryServiceError.coreData(error)
            }
        }
    }

    // 将某个 scope 下的远端模型应用到本地：增量更新/插入、维护关系、清理本地多余记录
    private func apply(models: [BillMainCategory], scope: BillCategoryScope, in context: NSManagedObjectContext) throws {
        let scopeValue: Int16 = (scope == .public) ? 0 : 1

        // 现有主分类
        let mainFetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BillMainCategoryEntity")
        mainFetch.predicate = NSPredicate(format: "scope == %d", scopeValue)
        let existingMain = try context.fetch(mainFetch)

        // 现有子分类
        let subFetch: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "BillSubCategoryEntity")
        subFetch.predicate = NSPredicate(format: "scope == %d", scopeValue)
        let existingSub = try context.fetch(subFetch)

        var mainByID: [String: NSManagedObject] = [:]
        for obj in existingMain {
            if let id = obj.value(forKey: "id") as? String {
                mainByID[id] = obj
            }
        }

        var subByID: [String: NSManagedObject] = [:]
        for obj in existingSub {
            if let id = obj.value(forKey: "id") as? String {
                subByID[id] = obj
            }
        }

        // 将远端 id 记录下来，用于清理
        let remoteMainIDs = Set(models.map { $0.id })
        let remoteSubIDs = Set(models.flatMap { $0.subCategories.map { $0.id } })

        // 应用/更新主分类
        for main in models {
            let mainEntity: NSManagedObject
            if let existing = mainByID[main.id] {
                mainEntity = existing
            } else {
                let entityDesc = NSEntityDescription.entity(forEntityName: "BillMainCategoryEntity", in: context)!
                mainEntity = NSManagedObject(entity: entityDesc, insertInto: context)
                mainEntity.setValue(main.id, forKey: "id")
                mainByID[main.id] = mainEntity
            }
            if !main.name.isEmpty {
                mainEntity.setValue(main.name, forKey: "name")
            }
            mainEntity.setValue(scopeValue, forKey: "scope")
        }

        // 应用/更新子分类并建立关系
        for main in models {
            guard let mainEntity = mainByID[main.id] else { continue }
            for sub in main.subCategories {
                let subEntity: NSManagedObject
                if let existing = subByID[sub.id] {
                    subEntity = existing
                } else {
                    let entityDesc = NSEntityDescription.entity(forEntityName: "BillSubCategoryEntity", in: context)!
                    subEntity = NSManagedObject(entity: entityDesc, insertInto: context)
                    subEntity.setValue(sub.id, forKey: "id")
                    subByID[sub.id] = subEntity
                }
                if !sub.name.isEmpty {
                    subEntity.setValue(sub.name, forKey: "name")
                }
                subEntity.setValue(scopeValue, forKey: "scope")
                subEntity.setValue(mainEntity, forKey: "mainCategory")
            }
        }

        // 清理本地多余记录（该 scope 下）
        for (id, obj) in mainByID where !remoteMainIDs.contains(id) {
            context.delete(obj)
        }
        for (id, obj) in subByID where !remoteSubIDs.contains(id) {
            context.delete(obj)
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
    public init() {}
    public init(container: Any? = nil) {}

    public func fetchPublicCategories() async throws -> [BillMainCategory] {
        throw BillCategoryServiceError.unavailable
    }

    public func fetchPrivateCategories() async throws -> [BillMainCategory] {
        throw BillCategoryServiceError.unavailable
    }

    public func fetchAllCategories() async throws -> [BillMainCategory] {
        throw BillCategoryServiceError.unavailable
    }

    @discardableResult
    public func createPrivateMainCategory(name: String) async throws -> BillMainCategory {
        throw BillCategoryServiceError.unavailable
    }

    @discardableResult
    public func createPrivateSubCategory(name: String, mainCategoryID: String) async throws -> BillSubCategory {
        throw BillCategoryServiceError.unavailable
    }
}

#endif
