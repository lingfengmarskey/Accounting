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

public struct CategoriesStore: Reducer {
    public struct State: Equatable {
        var categories: [BillMainCategoryModel]
        var selectedCategory: BillMainCategoryModel?

        public init(categories: [BillMainCategoryModel] = [], selectedCategory: BillMainCategoryModel? = nil) {
            self.categories = categories
            self.selectedCategory = selectedCategory
        }
    }

    public enum Action: Equatable {
        case onAppear
        case onTap(BillModel)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onTap(bill):
                
                return .none
            default:
                return .none
            }
        }
    }
}
