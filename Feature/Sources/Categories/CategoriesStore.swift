//
//  CategoriesStore.swift
//  
//
//  Created by Marcos Meng on 2023/12/31.
//

import Foundation
import ComposableArchitecture
import Core
import Domain
@Reducer
public struct CategoriesStore {
    @ObservableState
    public struct State {
        var categories: [BillMainCategory]
        var selectedCategory: BillMainCategory?

        public init(categories: [BillMainCategory] = [],
                    selectedCategory: BillMainCategory? = nil
        ) {
            self.categories = categories
            self.selectedCategory = selectedCategory
        }
    }

    public enum Action {
        case onAppear
        case onTap(BillMainCategory)
        case categoriesResponse(TaskResult<[BillMainCategory]>)
    }

    public init() {}

    @Dependency(\.billCategoryClient) public var billCategoryClient

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [billCategoryClient] send in
                    await send(.categoriesResponse(TaskResult {
                        try await billCategoryClient.fetchAllCategories()
                    }))
                }
            case let .onTap(category):
                state.selectedCategory = category
                return .none
            case let .categoriesResponse(.success(categories)):
                state.categories = categories
                if let selectedID = state.selectedCategory?.id {
                    state.selectedCategory = categories.first(where: { $0.id == selectedID })
                }
                return .none
            case .categoriesResponse(.failure):
                state.categories = []
                state.selectedCategory = nil
                return .none
            }
        }
    }
}
