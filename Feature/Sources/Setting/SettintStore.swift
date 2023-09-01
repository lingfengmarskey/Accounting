//
//  SettintStore.swift
//  
//
//  Created by Marcos Meng on 2022/08/22.
//

import Foundation
import ComposableArchitecture
import UIKit
import Core

public enum SettingStore {
    public struct Environment {
        public var backgroundQueue: AnySchedulerOf<DispatchQueue>
        public var preferences: PreferencesProtocol
        
        public init(
            backgroundQueue: AnySchedulerOf<DispatchQueue>,
            preferences: PreferencesProtocol
        ) {
            self.backgroundQueue = backgroundQueue
            self.preferences = preferences
        }

        public static let live = Self(
            backgroundQueue: .main,
            preferences: Preferences()
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
    > { state, action, env in
        switch action {
        case .onAppear:
            if let currentBookId = env.preferences.value(forKey: "currentBook") as? String {
                // check current book id is validate
                
            } else {
                state.bookState = .notChoosen
            }
            return .none
        default:
            return .none
        }
    }
}
