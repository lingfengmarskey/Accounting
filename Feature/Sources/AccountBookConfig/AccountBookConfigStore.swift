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
import ParticipatorDetail

public struct AccountBookConfigStore: Reducer {
    public struct State: Equatable {
        @BindingState var name: String = ""

        public var book: AccountBookModel?

        var paticipators: [ParticipacerModel] = .stub()
        
        var saveDisable: Bool = true
        
        var sharedLink: String = ""
        
        @BindingState var shouldShared: Bool = false

        @PresentationState var destination: Destination.State?

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
        case destination(PresentationAction<Destination.Action>)
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
                state.destination = nil
                return .none
            case .binding:
                return .none
            case let .tapUser(id):
                if let id = id,
                   let model = state.paticipators.first(where: { $0.id == id }) {
                    state.destination = .participatorDetail(.init(participator: model))
                    state.shouldShared = false
                } else {
                    state.destination = nil
                    // TODO: config sharelink
                    state.sharedLink = "www.baidu.com"
                    state.shouldShared = true
                }
                return .none
            case .destination(.presented(.participatorDetail(.tapBack))):
                state.destination = nil
                return .none
            default:
                return .none
            }
        }
    }

    public struct Destination: Reducer {
        public enum State: Equatable {
            case participatorDetail(ParticipatorDetailStore.State)
        }
        public enum Action: Equatable {
            case participatorDetail(ParticipatorDetailStore.Action)
        }
        public var body: some Reducer<State, Action> {
            Scope(state: /State.participatorDetail, action: /Action.participatorDetail) {
                ParticipatorDetailStore()
            }
        }
    }
}
