//
//  File.swift
//
//
//  Created by Marcos Meng on 2023/10/06.
//

import ComposableArchitecture
import Core
import Foundation
import ParticipatorDetail
import SwiftUI
import CoreData

@Reducer
public struct AccountBookConfigStore {
    @ObservableState
    public struct State {
        var name: String = ""

        public var book: AccountBook?

        var paticipators: [Participacer] = []

        var saveDisable: Bool {
            name.isEmpty
        }
        
        var isCreate: Bool

        var sharedLink: String = ""

        var shouldShared: Bool = false

        @Presents var destination: Destination.State?

        public init(
            book: AccountBook? = nil
        ) {
            self.book = book
            self.isCreate = book == nil
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case addMember
        case tapUser(String?)
        case tapTopDone
        case tapTopCancel
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)
    }

    @Dependency(\.ledgerClient) public var ledgerClient

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
                   let model = state.paticipators.first(where: { $0.id == id })
                {
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
            case .tapTopDone:
//                DataManager.shared.createAccountBook(name: state.name) { error in
//                    print("result is \(error)")
//                }
                // TODO: safe logics
                    return .run { send in
                        await ledgerClient.addLedger("", "")
                    }
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }

    @Reducer
    public enum Destination {
        case participatorDetail(ParticipatorDetailStore)
    }
}
