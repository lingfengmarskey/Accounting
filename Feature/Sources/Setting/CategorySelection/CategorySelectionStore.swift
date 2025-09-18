import ComposableArchitecture
import Core

public struct CategorySelectionStore: Reducer {
    public struct State: Equatable {
        public var categories: [BillMainCategoryModel]
        public var isLoading: Bool
        public var errorMessage: String?
        public var newMainCategoryName: String
        public var selectedMainCategoryID: String?
        public var newSubCategoryName: String

        public init(
            categories: [BillMainCategoryModel] = [],
            isLoading: Bool = false,
            errorMessage: String? = nil,
            newMainCategoryName: String = "",
            selectedMainCategoryID: String? = nil,
            newSubCategoryName: String = ""
        ) {
            self.categories = categories
            self.isLoading = isLoading
            self.errorMessage = errorMessage
            self.newMainCategoryName = newMainCategoryName
            self.selectedMainCategoryID = selectedMainCategoryID
            self.newSubCategoryName = newSubCategoryName
        }
    }

    public enum Action {
        case onAppear
        case refresh
        case categoriesResponse(TaskResult<[BillMainCategoryModel]>)
        case setNewMainCategoryName(String)
        case setNewSubCategoryName(String)
        case selectMainCategory(String?)
        case createMainCategory
        case createMainCategoryResponse(TaskResult<BillMainCategoryModel>)
        case createSubCategory
        case createSubCategoryResponse(String, TaskResult<BillSubCategoryModel>)
        case clearError
    }

    private let service: BillCategoryService

    public init(service: BillCategoryService = BillCategoryService()) {
        self.service = service
    }

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear, .refresh:
                state.isLoading = true
                state.errorMessage = nil
                return .run { [service] send in
                    await send(.categoriesResponse(TaskResult {
                        try await service.fetchAllCategories()
                    }))
                }

            case let .categoriesResponse(.success(categories)):
                state.isLoading = false
                state.categories = categories.sorted(by: { lhs, rhs in
                    switch (lhs.scope, rhs.scope) {
                    case (.public, .private):
                        return true
                    case (.private, .public):
                        return false
                    default:
                        return lhs.name.localizedCompare(rhs.name) == .orderedAscending
                    }
                })
                state.errorMessage = nil
                return .none

            case let .categoriesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case let .setNewMainCategoryName(text):
                state.newMainCategoryName = text
                return .none

            case let .setNewSubCategoryName(text):
                state.newSubCategoryName = text
                return .none

            case let .selectMainCategory(identifier):
                state.selectedMainCategoryID = identifier
                return .none

            case .createMainCategory:
                let trimmed = state.newMainCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    state.errorMessage = "请输入大分类名称"
                    return .none
                }

                state.isLoading = true
                state.errorMessage = nil
                state.newMainCategoryName = ""

                return .run { [service] send in
                    await send(.createMainCategoryResponse(TaskResult {
                        try await service.createPrivateMainCategory(name: trimmed)
                    }))
                }

            case let .createMainCategoryResponse(.success(category)):
                state.isLoading = false
                state.errorMessage = nil
                state.categories.append(category)
                state.categories.sort(by: { lhs, rhs in
                    switch (lhs.scope, rhs.scope) {
                    case (.public, .private):
                        return true
                    case (.private, .public):
                        return false
                    default:
                        return lhs.name.localizedCompare(rhs.name) == .orderedAscending
                    }
                })
                return .none

            case let .createMainCategoryResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .createSubCategory:
                guard let parentID = state.selectedMainCategoryID else {
                    state.errorMessage = "请选择所属的大分类"
                    return .none
                }

                let trimmed = state.newSubCategoryName.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else {
                    state.errorMessage = "请输入小分类名称"
                    return .none
                }

                state.isLoading = true
                state.errorMessage = nil
                state.newSubCategoryName = ""

                return .run { [service] send in
                    await send(.createSubCategoryResponse(parentID, TaskResult {
                        try await service.createPrivateSubCategory(name: trimmed, mainCategoryID: parentID)
                    }))
                }

            case let .createSubCategoryResponse(parentID, .success(subCategory)):
                state.isLoading = false
                state.errorMessage = nil

                if let index = state.categories.firstIndex(where: { $0.id == parentID }) {
                    let category = state.categories[index]
                    var subCategories = category.subCategories
                    subCategories.append(subCategory)
                    subCategories.sort(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
                    state.categories[index] = BillMainCategoryModel(
                        id: category.id,
                        name: category.name,
                        subCategories: subCategories,
                        scope: category.scope
                    )
                } else {
                    state.categories.append(
                        BillMainCategoryModel(
                            id: parentID,
                            name: parentID,
                            subCategories: [subCategory],
                            scope: .private
                        )
                    )
                }
                return .none

            case let .createSubCategoryResponse(_, .failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            case .clearError:
                state.errorMessage = nil
                return .none
            }
        }
    }
}
