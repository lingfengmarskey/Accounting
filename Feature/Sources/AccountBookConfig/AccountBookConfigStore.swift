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

@Reducer
public struct AccountBookConfigStore {
    @ObservableState
    public struct State {
        var name: String = ""

        public var book: AccountBook?

        var paticipators: [Participacer] = []

        var originalName: String = ""

        var isSaving: Bool = false

        var saveDisable: Bool {
            trimmedName.isEmpty || isSaving
        }

        var isCreate: Bool

        var sharedLink: String = ""

        var shouldShared: Bool = false

        var trimmedName: String {
            name.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var hasEdits: Bool {
            if isCreate {
                return !trimmedName.isEmpty
            }
            return trimmedName != originalName.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?

        public init(
            book: AccountBook? = nil
        ) {
            self.book = book
            self.isCreate = book == nil
            if let book {
                self.name = book.name
                self.originalName = book.name
                self.paticipators = book.participacer
            }
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case addMember
        case tapUser(String?)
        case tapTopDone
        case tapTopCancel
        case cancelConfirmed
        case saveResponse(Result<AccountBook, Error>)
        case destination(PresentationAction<Destination.Action>)
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<State>)
    
        public enum Alert: Equatable {
            case confirmDiscard
            case acknowledgeFailure
        }
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
                    state.originalName = book.name
                    state.isCreate = false
                } else {
                    state.name = ""
                    state.originalName = ""
                    state.paticipators = []
                    state.isCreate = true
                }
                state.destination = nil
                state.shouldShared = false
                state.sharedLink = ""
                state.isSaving = false
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
                if state.saveDisable {
                    return .none
                }
                state.isSaving = true
                if state.isCreate {
                    let title = state.trimmedName
                    let ownerID = state.book?.owner.id ?? UUID().uuidString
                    let ownerName = state.book?.owner.name ?? "Owner"
                    return .run { send in
                        await send(
                            .saveResponse(
                                TaskResult {
                                    try await ledgerClient.addLedger(title, ownerID, ownerName)
                                }
                            )
                        )
                    }
                } else if var book = state.book {
                    book.name = state.trimmedName
                    state.book = book
                    state.originalName = book.name
                    return .send(.saveResponse(.success(book)))
                }
                return .none
            case .saveResponse(.success(let book)):
                state.book = book
                state.isCreate = false
                state.originalName = book.name
                state.name = book.name
                state.paticipators = book.participacer
                state.isSaving = false
                return .none
            case .saveResponse(.failure):
                state.isSaving = false
                state.alert = AlertState(
                    title: TextState("Save Failed"),
                    message: TextState("Please try again."),
                    buttons: [
                        .default(TextState("OK"), action: .send(.acknowledgeFailure))
                    ]
                )
                return .none
            case .tapTopCancel:
                if state.hasEdits {
                    state.alert = AlertState(
                        title: TextState("Discard changes?"),
                        message: TextState("Your current edits will be lost."),
                        buttons: [
                            .destructive(TextState("Discard"), action: .send(.confirmDiscard)),
                            .cancel(TextState("Keep Editing"))
                        ]
                    )
                    return .none
                }
                return .send(.cancelConfirmed)
            case .cancelConfirmed:
                state.alert = nil
                state.isSaving = false
                return .none
            case .alert(.presented(.confirmDiscard)):
                return .send(.cancelConfirmed)
            case .alert(.presented(.acknowledgeFailure)):
                state.alert = nil
                return .none
            case .alert:
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$alert, action: \.alert)
    }

    @Reducer
    public enum Destination {
        case participatorDetail(ParticipatorDetailStore)
    }
}
