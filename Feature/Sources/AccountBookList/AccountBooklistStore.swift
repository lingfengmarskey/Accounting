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

        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case toTop
        case addBook
    }
    
    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .addBook:
                // move to addBook
                
                return .none
            default:
                return .none
            }
        }
    }
    

//    public static let reducer = Reducer<
//        State, Action, Environment
//    > { state, action, env in
//        switch action {
//        case .onAppear:
//            return .none
//        case .addBook:
//            // move to addBook
//
//            return .none
//        default:
//            return .none
//        }
//    }
//    #if DEBUG
//    .debug()
//    #endif
    
}
