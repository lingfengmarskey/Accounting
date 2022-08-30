//
//  SettintStore.swift
//  
//
//  Created by Marcos Meng on 2022/08/22.
//

import Foundation
import ComposableArchitecture
import UIKit

public enum SettingStore {
    public struct Environment {
        public var backgroundQueue: AnySchedulerOf<DispatchQueue>

        public init(
            backgroundQueue: AnySchedulerOf<DispatchQueue>
        ) {
            self.backgroundQueue = backgroundQueue
        }

        public static let live = Self(
            backgroundQueue: .main
        )
    }
    
    public enum Action: Equatable {
        case tapBook
        case none
        case onAppear
    }

    public struct State: Equatable {
        var bookState: BookState = .notChoosen
        public init(
            bookState: BookState
        ) {
            self.bookState = bookState
        }
    }

    public enum BookState: Equatable {
        case normal(String)
        case error
        case notChoosen

        public var text: String {
            switch self {
            case .normal(let string):
                return string
            case .error:
                return "Error"
            case .notChoosen:
                return "未选择"
            }
        }
    }
    
    
    public static let reducer = Reducer<
        State, Action, Environment
    > { _, action, _ in
        switch action {
        default:
            return .none
        }
    }
}
