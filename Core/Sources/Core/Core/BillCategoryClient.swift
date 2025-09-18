import Foundation
import CloudKit
import ComposableArchitecture

// 1) 封装对外接口，便于在 Store 中通过 @Dependency 注入调用
public struct BillCategoryClient {
    public var fetchPublicCategories: @Sendable () async throws -> [BillMainCategory]
    public var fetchPrivateCategories: @Sendable () async throws -> [BillMainCategory]
    public var fetchAllCategories: @Sendable () async throws -> [BillMainCategory]
    public var createPrivateMainCategory: @Sendable (_ name: String) async throws -> BillMainCategory
    public var createPrivateSubCategory: @Sendable (_ name: String, _ mainCategoryID: String) async throws -> BillSubCategory
}

// 2) 依赖键
public enum BillCategoryClientKey: DependencyKey {
    // 默认使用 live 实现
    public static let liveValue: BillCategoryClient = .live
}

// 3) 便捷访问
public extension DependencyValues {
    var billCategoryClient: BillCategoryClient {
        get { self[BillCategoryClientKey.self] }
        set { self[BillCategoryClientKey.self] = newValue }
    }
}

// 4) 具体实现
public extension BillCategoryClient {
    // 生产环境实现，内部委托给 BillCategoryService
    static let live = BillCategoryClient(
        fetchPublicCategories: {
            try await BillCategoryService.shared.fetchPublicCategories()
        },
        fetchPrivateCategories: {
            try await BillCategoryService.shared.fetchPrivateCategories()
        },
        fetchAllCategories: {
            try await BillCategoryService.shared.fetchAllCategories()
        },
        createPrivateMainCategory: { name in
            try await BillCategoryService.shared.createPrivateMainCategory(name: name)
        },
        createPrivateSubCategory: { name, mainCategoryID in
            try await BillCategoryService.shared.createPrivateSubCategory(name: name, mainCategoryID: mainCategoryID)
        }
    )

}
