//
//  File.swift
//
//
//  Created by Marcos Meng on 2023/10/06.
//

import ComposableArchitecture
import Core
import Foundation
import SwiftUI

public struct AccountBookConfigStore: Reducer {
    public struct State: Equatable {
        @BindingState var name: String = ""

        public var book: AccountBookModel?

        var paticipators: [ParticipacerModel] = .stub()

        public init(
            book: AccountBookModel? = nil
        ) {
            self.book = book
        }
    }

    public enum Action: BindableAction, Equatable {
        case onAppear
        case addMember
        case tapUser(String?)
        case tapTopDone
        case tapTopCancel
        case binding(BindingAction<State>)
    }

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                if let book = state.book {
                    state.name = book.name
                    state.paticipators = book.participacer
                }
                return .none
            case .binding:
                return .none
            case let .tapUser(id):
                // TODO: add or select
                return .none
            default:
                return .none
            }
        }
    }
}
