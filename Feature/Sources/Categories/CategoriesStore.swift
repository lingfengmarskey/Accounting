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
        var categories: [BillMainCategory]
        var selectedCategory: BillMainCategory?

        public init(categories: [BillMainCategory] = .stub(), 
                    selectedCategory: BillMainCategory? = nil
        ) {
            self.categories = categories
            self.selectedCategory = selectedCategory
        }
    }

    public enum Action: Equatable {
        case onAppear
        case onTap(BillMainCategory)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onTap(category):
                state.selectedCategory = category
                return .none
            }
        }
    }
}
