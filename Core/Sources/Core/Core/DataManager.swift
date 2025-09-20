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
import ComposableArchitecture
import Domain

public enum LedgerDataClientKey: DependencyKey {
  public static let liveValue: LedgerDataClient = .live
}

public extension DependencyValues {
var ledgerClient: LedgerDataClient {
    get { self[LedgerDataClientKey.self] }
    set { self[LedgerDataClientKey.self] = newValue }
  }
}

public struct LedgerDataClient {
    public var fetchLedgers: @Sendable () async -> [AccountBook]
    public var addLedger: @Sendable (_ title: String, _ ownerID: String, _ ownerName: String) async throws -> AccountBook
    public var deleteLedger: @Sendable (String) async -> Void // ledger ID
}

public enum LedgerDataClientError: Error {
    case saveFailed
}

public enum TransactionDataClientKey: DependencyKey {
  public static let liveValue: TransactionDataClient = .live
}

public extension DependencyValues {
var transactionClient: TransactionDataClient {
    get { self[TransactionDataClientKey.self] }
    set { self[TransactionDataClientKey.self] = newValue }
  }
}

public struct TransactionDataClient {
    public var addBill: @Sendable (_ ledger: AccountBook, _ value: Double, _ type: BillType, _ mainCategory: BillMainCategory, _ subCategory: BillSubCategory, _ date: Date, _ description: String?) async throws -> Bill
}

public enum TransactionDataClientError: Error {
    case ledgerNotFound
    case saveFailed
}

public enum CurrencyDataClientKey: DependencyKey {
    public static let liveValue: CurrencyDataClient = .live
}

public extension DependencyValues {
    var currencyClient: CurrencyDataClient {
        get { self[CurrencyDataClientKey.self] }
        set { self[CurrencyDataClientKey.self] = newValue }
    }
}

public struct CurrencyDataClient {
    public var fetchLocalCurrencies: @Sendable () async -> [CurrencyModel]
    public var syncFromCloud: @Sendable () async throws -> [CurrencyModel]
}

public enum CurrencyDataClientError: LocalizedError {
    case saveFailed(Error)

    public var errorDescription: String? {
        switch self {
        case let .saveFailed(error):
            return "保存汇率数据失败：\(error.localizedDescription)"
        }
    }
}

extension CurrencyDataClient {
    public static let live = CurrencyDataClient(
        fetchLocalCurrencies: {
            let context = PersistenceController.shared.container.viewContext
            return await fetchCurrencies(in: context)
        },
        syncFromCloud: {
            let database = CKContainer(identifier: Config.containerIdentifier).publicCloudDatabase
            let records = try await fetchCurrencyRecords(from: database)
            let models = records.compactMap(CurrencyModel.init(record:))
            let latestByRecordName = models.reduce(into: [String: CurrencyModel]()) { partialResult, model in
                if let existing = partialResult[model.recordName], existing.modifiedAt >= model.modifiedAt {
                    return
                }
                partialResult[model.recordName] = model
            }
            let syncedRecordNames = Set(latestByRecordName.keys)

            let container = PersistenceController.shared.container
            let backgroundContext = container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            try await backgroundContext.perform {
                let fetchRequest = NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
                let existingEntities = try backgroundContext.fetch(fetchRequest)
                var entitiesByRecordName: [String: CurrencyEntity] = [:]

                for entity in existingEntities {
                    guard let recordName = entity.recordName else {
                        backgroundContext.delete(entity)
                        continue
                    }

                    if syncedRecordNames.contains(recordName) {
                        entitiesByRecordName[recordName] = entity
                    } else {
                        backgroundContext.delete(entity)
                    }
                }

                for (recordName, model) in latestByRecordName {
                    let entity = entitiesByRecordName[recordName] ?? CurrencyEntity(context: backgroundContext)
                    model.apply(to: entity)
                    entitiesByRecordName[recordName] = entity
                }

                if backgroundContext.hasChanges {
                    do {
                        try backgroundContext.save()
                    } catch {
                        backgroundContext.reset()
                        throw CurrencyDataClientError.saveFailed(error)
                    }
                }
            }

            return await fetchCurrencies(in: container.viewContext)
        }
    )

    public static let stub = CurrencyDataClient(
        fetchLocalCurrencies: {
            [CurrencyModel].stub()
        },
        syncFromCloud: {
            [CurrencyModel].stub()
        }
    )
}

extension LedgerDataClient {
    public static let live = LedgerDataClient(
        fetchLedgers: {
            let container = PersistenceController.shared.container
            let backgroundContext = container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            let objectIDs: [NSManagedObjectID] = await backgroundContext.perform {
                let request = NSFetchRequest<NSManagedObjectID>(entityName: "LedgerEntity")
                request.sortDescriptors = [NSSortDescriptor(keyPath: \LedgerEntity.createdAt, ascending: false)]
                request.resultType = .managedObjectIDResultType
                do {
                    return try backgroundContext.fetch(request)
                } catch {
                    return []
                }
            }

            let viewContext = container.viewContext
            return await viewContext.perform {
                objectIDs.compactMap { objectID in
                    guard let ledger = try? viewContext.existingObject(with: objectID) as? LedgerEntity else {
                        return nil
                    }
                    return LedgerAdapter.from(entity: ledger)
                }
            }
        },
        addLedger: { title, ownerID, ownerName in
            let container = PersistenceController.shared.container
            let backgroundContext = container.newBackgroundContext()
            backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

            let objectID: NSManagedObjectID = try await backgroundContext.perform {
                let ledger = LedgerEntity(context: backgroundContext)
                ledger.id = UUID().uuidString
                ledger.title = title
                ledger.createdAt = Date()
                ledger.ownerID = ownerID
                ledger.ownerName = ownerName
                ledger.recordName = UUID().uuidString

                do {
                    try backgroundContext.obtainPermanentIDs(for: [ledger])
                    try backgroundContext.save()
                } catch {
                    backgroundContext.rollback()
                    throw LedgerDataClientError.saveFailed
                }

                return ledger.objectID
            }

            let viewContext = container.viewContext
            return try await viewContext.perform {
                guard let ledger = try viewContext.existingObject(with: objectID) as? LedgerEntity else {
                    throw LedgerDataClientError.saveFailed
                }
                return LedgerAdapter.from(entity: ledger)
            }
        },
        deleteLedger: { id in
            let context = PersistenceController.shared.container.viewContext
            let request: NSFetchRequest<LedgerEntity> = LedgerEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            if let result = try? context.fetch(request), let ledger = result.first {
                context.delete(ledger)
                try? context.save()
            }
        }
    )
    
    public static let mock = LedgerDataClient {
        []
    } addLedger: { title, ownerID, ownerName in
        AccountBook(
            owner: .init(id: ownerID, name: ownerName),
            participacer: [],
            bills: [],
            id: UUID().uuidString,
            name: title,
            createdAt: Date().ISO8601Format()
        )
    } deleteLedger: { _ in }

}

extension TransactionDataClient {
    public static let live = TransactionDataClient { ledger, value, type, mainCategory, subCategory, date, description in
        let container = PersistenceController.shared.container
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        let transactionObjectID: NSManagedObjectID = try await backgroundContext.perform {
            let request: NSFetchRequest<LedgerEntity> = LedgerEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", ledger.id)

            let ledgerResults = try backgroundContext.fetch(request)
            guard let ledgerEntity = ledgerResults.first else {
                throw TransactionDataClientError.ledgerNotFound
            }

            let transaction = TransactionEntity(context: backgroundContext)
            transaction.id = UUID().uuidString
            transaction.value = value
            transaction.type = type.rawValue
            transaction.createdAt = date
            transaction.updatedAt = date
            transaction.descriptionContent = description
            transaction.book = ledgerEntity

            let mainCategoryEntity = try fetchOrCreateMainCategoryEntity(from: mainCategory, context: backgroundContext)
            let subCategoryEntity = try fetchOrCreateSubCategoryEntity(from: subCategory, mainCategoryEntity: mainCategoryEntity, context: backgroundContext)
            let userEntity = try fetchOrCreateUserEntity(from: ledger.owner, context: backgroundContext)

            transaction.mainCategory = mainCategoryEntity
            transaction.subCategory = subCategoryEntity
            transaction.createdByUser = userEntity
            transaction.updatedByUser = userEntity

            do {
                try backgroundContext.obtainPermanentIDs(for: [transaction, mainCategoryEntity, subCategoryEntity, userEntity])
                try backgroundContext.save()
            } catch {
                backgroundContext.rollback()
                throw TransactionDataClientError.saveFailed
            }

            return transaction.objectID
        }

        let viewContext = container.viewContext
        return try await viewContext.perform {
            guard let transaction = try viewContext.existingObject(with: transactionObjectID) as? TransactionEntity else {
                throw TransactionDataClientError.saveFailed
            }
            return BillAdapter.from(entity: transaction)
        }
    }
}

private func fetchCurrencies(in context: NSManagedObjectContext) async -> [CurrencyModel] {
    await context.perform {
        let request = NSFetchRequest<CurrencyEntity>(entityName: "CurrencyEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "shortName", ascending: true)]
        let entities = (try? context.fetch(request)) ?? []
        return entities.compactMap { $0.toModel() }
    }
}

private func fetchCurrencyRecords(from database: CKDatabase) async throws -> [CKRecord] {
    var allRecords: [CKRecord] = []
    var cursor: CKQueryOperation.Cursor?

    repeat {
        if let currentCursor = cursor {
            let response = try await database.records(continuingMatchFrom: currentCursor)
            try response.matchResults.forEach { _, result in
                switch result {
                case let .success(record):
                    allRecords.append(record)
                case let .failure(error):
                    throw error
                }
            }
            cursor = response.queryCursor
        } else {
            let query = CKQuery(recordType: "CurrencyEntity", predicate: NSPredicate(value: true))
            let response = try await database.records(matching: query)
            try response.matchResults.forEach { _, result in
                switch result {
                case let .success(record):
                    allRecords.append(record)
                case let .failure(error):
                    throw error
                }
            }
            cursor = response.queryCursor
        }
    } while cursor != nil

    return allRecords
}

public struct LedgerAdapter {
    static func from(entity: LedgerEntity) -> AccountBook {
        // owner 对象
        let owner = User(
            id: entity.ownerID ?? "",
            name: entity.ownerName ?? ""
        )
        
        // participacer 列表
        let participacers: [Participacer]
        if let set = entity.participacers {
            participacers = set.convertToParticipacers(permission: .read)
        } else {
            participacers = []
        }
        
        // bills 列表（实际为 TransactionEntity）
        let bills: [Bill]
        if let transactionSet = entity.bills as? Set<TransactionEntity> {
            bills = transactionSet.compactMap { BillAdapter.from(entity: $0) }
        } else {
            bills = []
        }
        
        // 时间格式化
        let dateFormatter = ISO8601DateFormatter()
        let createdAtString = entity.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        
        // AccountBook 组装
        return AccountBook(
            owner: owner,
            participacer: participacers,
            bills: bills,
            id: entity.id ?? "",
            name: entity.title ?? "",
            createdAt: createdAtString
        )
    }
}

public struct BillAdapter {
    static func from(entity: TransactionEntity) -> Bill {
        // 账单类型
        let billType = BillType(rawValue: entity.type ?? "0") ?? .payment

        // 主分类
        let mainCategory = BillMainCategory(
            id: entity.mainCategory?.id ?? "",
            name: entity.mainCategory?.name ?? "",
            subCategories: [] // 如需详细子类，请关联转换
        )
        // 子分类
        let subCategory = BillSubCategory(
            id: entity.subCategory?.id ?? "",
            name: entity.subCategory?.name ?? ""
        )
        
        // 创建人
        let createdBy = User(
            id: entity.createdByUser?.id ?? "",
            name: entity.createdByUser?.name ?? ""
        )
        let updatedBy = User(
            id: entity.updatedByUser?.id ?? "",
            name: entity.updatedByUser?.name ?? ""
        )
        
        // 时间格式化
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = entity.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let updatedAt = entity.updatedAt.map { dateFormatter.string(from: $0) } ?? ""
        
        return Bill(
            id: entity.id ?? "",
            value: entity.value,
            type: billType,
            mainCategory: mainCategory,
            subCategory: subCategory,
            createdAt: createdAt,
            updatedAt: updatedAt,
            createdByUser: createdBy,
            updatedByUser: updatedBy,
            description: entity.descriptionContent ?? ""
        )
    }
}

private func fetchOrCreateMainCategoryEntity(from category: BillMainCategory, context: NSManagedObjectContext) throws -> BillMainCategoryEntity {
    let request: NSFetchRequest<BillMainCategoryEntity> = BillMainCategoryEntity.fetchRequest()
    if let uuid = UUID(uuidString: category.id) {
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    } else {
        request.predicate = NSPredicate(value: false)
    }

    if let existing = try context.fetch(request).first {
        existing.name = category.name
        return existing
    }

    let entity = BillMainCategoryEntity(context: context)
    entity.id = category.id
    entity.name = category.name
    return entity
}

private func fetchOrCreateSubCategoryEntity(from category: BillSubCategory, mainCategoryEntity: BillMainCategoryEntity, context: NSManagedObjectContext) throws -> BillSubCategoryEntity {
    let request: NSFetchRequest<BillSubCategoryEntity> = BillSubCategoryEntity.fetchRequest()
    if let uuid = UUID(uuidString: category.id) {
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
    } else {
        request.predicate = NSPredicate(value: false)
    }

    if let existing = try context.fetch(request).first {
        existing.name = category.name
        existing.mainCategory = mainCategoryEntity
        return existing
    }

    let entity = BillSubCategoryEntity(context: context)
    entity.id = category.id
    entity.name = category.name
    entity.mainCategory = mainCategoryEntity
    return entity
}

private func fetchOrCreateUserEntity(from user: User, context: NSManagedObjectContext) throws -> UserEntity {
    let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()

    request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)

    if let existing = try context.fetch(request).first {
        existing.name = user.name
        return existing
    }

    let entity = UserEntity(context: context)
    entity.id = user.id
    entity.name = user.name
    return entity
}

class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer

    public init(inMemory: Bool = false,
                ckContainerId: String = Config.containerIdentifier) {

        // 1) 从包资源中加载 .momd 或 .mom
        let bundle = Bundle.module
        guard let modelURL =
          bundle.url(forResource: Config.container, withExtension: "momd")
          ?? bundle.url(forResource: Config.container, withExtension: "mom"),
          let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
          fatalError("❌ 未找到 Core Data 模型 RecordBookData（检查包的 Resources 路径与模型名）")
        }

        // 2) 用 managedObjectModel 初始化容器
        container = NSPersistentCloudKitContainer(
          name: Config.container,
          managedObjectModel: model
        )

        // 3) 配置持久化描述 & CloudKit
        guard let description = container.persistentStoreDescriptions.first else {
          fatalError("❌ 无持久化描述")
        }

        description.cloudKitContainerOptions =
          NSPersistentCloudKitContainerOptions(containerIdentifier: ckContainerId)

        if inMemory {
          description.url = URL(fileURLWithPath: "/dev/null")
        }

        // 4) 载入
        container.loadPersistentStores { _, error in
          if let error { fatalError("💥 加载持久化存储失败: \(error)") }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
      }
    
    // MARK: - 预览用（SwiftUI Preview）

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // 示例 Ledger
        let ledger = LedgerEntity(context: context)
        ledger.id = UUID().uuidString
        ledger.title = "示例账本"
        ledger.createdAt = Date()
        ledger.ownerID = "previewUser"

        do {
            try context.save()
        } catch {
            print("❌ 保存预览数据失败: \(error)")
        }

        return controller
    }()
}

