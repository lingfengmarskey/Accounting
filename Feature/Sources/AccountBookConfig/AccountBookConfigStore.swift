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

        public var isEditable: Bool

        var paticipators: [Participacer] = []

        var originalName: String = ""

        var isSaving: Bool = false

        var saveDisable: Bool {
            trimmedName.isEmpty || isSaving || !isEditable
        }

        var isCreate: Bool

        var sharedLink: String = ""

        var shouldShared: Bool = false

        var trimmedName: String {
            name.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        var hasEdits: Bool {
            guard isEditable else { return false }
            if isCreate {
                return !trimmedName.isEmpty
            }
            return trimmedName != originalName.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        @Presents var destination: Destination.State?
        @Presents var alert: AlertState<Action.Alert>?

        public init(
            book: AccountBook? = nil,
            isEditable: Bool = true
        ) {
            self.book = book
            self.isEditable = isEditable
            self.isCreate = book == nil
            if let book {
                self.name = book.name
                self.originalName = book.name
                self.paticipators = book.participacer
            }
        }

        public static var none = State.init(book: nil)
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
        case onSaved   // << 新增：用于通知父级保存成功
    
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
                if !state.isEditable, id == nil {
                    return .none
                }
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
                if !state.isEditable || state.saveDisable {
                    return .none
                }
                state.isSaving = true
                if state.isCreate {
                    let title = state.trimmedName
                    let ownerID = state.book?.owner.id ?? UUID().uuidString
                    let ownerName = state.book?.owner.name ?? "Owner"
                    return .run { send in
                        let result = await Result {
                            try await ledgerClient.addLedger(title, ownerID, ownerName)
                        }
                        await send(.saveResponse(result))
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
                return .send(.onSaved)  // << 新增，通知父级保存完成做跳转
            case .saveResponse(.failure):
                state.isSaving = false
                state.alert = AlertState(
                    title: { TextState("Save Failed") },
                    actions: {
                        ButtonState(action: .send(.acknowledgeFailure), label: { TextState("OK") })
                    },
                    message: { TextState("Please try again.") }
                )
                return .none
            case .tapTopCancel:
                if state.hasEdits {
                    state.alert = AlertState(
                        title: { TextState("Discard changes?") },
                        actions: {
                            ButtonState(role: .destructive, action: .send(.confirmDiscard), label: { TextState("Discard") })
                            ButtonState(role: .cancel, action: .send(nil), label: { TextState("Keep Editing") })
                        },
                        message: { TextState("Your current edits will be lost.") }
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
            case .onSaved:
                // 这里通常交由父级处理，不用处理
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
