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
    public var addLedger: @Sendable (_ title: String, _ ownerID: String) async -> Void // title, ownerID
    public var deleteLedger: @Sendable (String) async -> Void // ledger ID
}

extension LedgerDataClient {
    public static let live = LedgerDataClient(
        fetchLedgers: {
            let context = PersistenceController.shared.container.viewContext
            let request: NSFetchRequest<LedgerEntity> = LedgerEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \LedgerEntity.createdAt, ascending: false)]
            let ledgers = (try? context.fetch(request)) ?? []
            let models = ledgers.map(LedgerAdapter.from)
            return models
        },
        addLedger: { title, ownerID in
            let context = PersistenceController.shared.container.viewContext
            let ledger = LedgerEntity(context: context)
            ledger.id = UUID().uuidString
            ledger.title = title
            ledger.createdAt = Date()
            ledger.ownerID = ownerID
            ledger.ownerName = nil
            ledger.recordName = UUID().uuidString
            try? context.save()
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
    } addLedger: { title, ownerID in
        
    } deleteLedger: { ledgerID in
        
    }

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
            id: entity.mainCategory?.id?.uuidString ?? "",
            name: entity.mainCategory?.name ?? "",
            subCategories: [] // 如需详细子类，请关联转换
        )
        // 子分类
        let subCategory = BillSubCategory(
            id: entity.subCategory?.id?.uuidString ?? "",
            name: entity.subCategory?.name ?? ""
        )
        
        // 创建人
        let createdBy = User(
            id: entity.createdByUser?.id?.uuidString ?? "",
            name: entity.createdByUser?.name ?? ""
        )
        let updatedBy = User(
            id: entity.updatedByUser?.id?.uuidString ?? "",
            name: entity.updatedByUser?.name ?? ""
        )
        
        // 时间格式化
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = entity.createdAt.map { dateFormatter.string(from: $0) } ?? ""
        let updatedAt = entity.updatedAt.map { dateFormatter.string(from: $0) } ?? ""
        
        return Bill(
            id: entity.id?.uuidString ?? "",
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
