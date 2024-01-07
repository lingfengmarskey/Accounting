//
//  SubCategoriesStore.swift
//
//
//  Created by Marcos Meng on 2024/01/07.
//

import Foundation
import ComposableArchitecture
import Domain
import Core

public struct SubCategoriesStore: Reducer {
    public struct State: Equatable {
        var subCategories: [BillSubCategoryModel]
        var selectedSubCategory: BillSubCategoryModel?

        public init(subCategories: [BillSubCategoryModel] = .stub(),
                    selectedSubCategory: BillSubCategoryModel? = nil
        ) {
            self.subCategories = subCategories
            self.selectedSubCategory = selectedSubCategory
        }
    }

    public enum Action: Equatable {
        case onAppear
        case onTap(BillSubCategoryModel)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onTap(category):
                state.selectedSubCategory = category
                return .none
            }
        }
    }
}
