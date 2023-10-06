//
//  File.swift
//  
//
//  Created by Marcos Meng on 2023/10/06.
//

import Foundation
import ComposableArchitecture
import Core
import SwiftUI

public struct AccountBookConfigStore: Reducer {

    public struct State: Equatable {

        @BindingState var name: String = ""

        var paticipators: [ParticipacerModel] = .stub()

        public init() {}
    }

    public enum Action: BindableAction, Equatable {
        case onAppear
        case addMember
        case tapUser(String?)
        case save
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .binding:
              return .none
            case .tapUser(let id):
                // TODO: add or select
                return .none
            default:
                return .none
            }
        }
    }
}

