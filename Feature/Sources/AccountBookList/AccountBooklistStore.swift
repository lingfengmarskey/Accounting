//
//  ViewModel.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//

import Foundation
import ComposableArchitecture
import Core

public struct AccountBooklistStore: Reducer {
    
    public struct State: Equatable {
        
        var books: [AccountBookModel] = .stub()
        var saveDisable: Bool {
            selected == nil
        }
        @BindingState var selected: String?

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case onAppear
        case toTop
        case addBook
        case removeItem(IndexSet)
        case binding(BindingAction<State>)
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .addBook:
                // TODO: move to addBook
                return .none
            case .removeItem(let index):
                // TODO: remove item
                state.selected = nil
                return .none
            case .binding:
              return .none
            default:
                return .none
            }
        }
    }
}
