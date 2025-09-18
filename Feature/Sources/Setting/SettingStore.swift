//
//  SettingStore.swift
//
//
//  Created by Marcos Meng on 2022/08/22.
//

import AccountBookList
import ComposableArchitecture
import Core
import Foundation
import UIKit

@Reducer
public struct SettingStore {
    @ObservableState
    public struct State {
        var bookState: BookState = .notChoosen
        var currentLedgerID: String?

        @Presents var destination: Destination.State?

        public init(
            bookState: BookState = .notChoosen,
            currentLedgerID: String? = nil
        ) {
            self.bookState = bookState
            self.currentLedgerID = currentLedgerID
        }
    }

    @Reducer
    public enum Destination {
        case selectBook(AccountBooklistStore)
    }

    public enum Action {
        case tapBook
        case none
        case onAppear
        case ledgersResponse(savedID: String?, ledgers: [AccountBook])
        case destination(PresentationAction<Destination.Action>)
        case delegate(DelegateAction)
    }

    public enum DelegateAction: Equatable {
        case didSelectLedger(AccountBook)
    }

    public enum BookState: Equatable {
        case normal(String)
        case error
        case notChoosen

        public var text: String {
            switch self {
            case let .normal(string):
                return string
            case .error:
                return "Error"
            case .notChoosen:
                return "未选择"
            }
        }
    }

    @Dependency(\.preferences) var preferences
    @Dependency(\.ledgerClient) var ledgerClient
    // TODO: depedency config
    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let savedID = preferences.value(forKey: "currentBook") as? String
                state.currentLedgerID = savedID
                return .run { [savedID] send in
                    let ledgers = await ledgerClient.fetchLedgers()
                    await send(.ledgersResponse(savedID: savedID, ledgers: ledgers))
                }
            case let .ledgersResponse(savedID, ledgers):
                if let savedID, let ledger = ledgers.first(where: { $0.id == savedID }) {
                    state.bookState = .normal(ledger.name)
                    state.currentLedgerID = ledger.id
                } else {
                    state.bookState = .notChoosen
                    state.currentLedgerID = nil
                }
                return .none
            case .tapBook:
                // TODO: check route
                // Mock:
                state.destination = .selectBook(.init(selected: state.currentLedgerID))
                return .none
            case .destination(.presented(.selectBook(.selectDone))):
                switch state.destination {
                case let .selectBook(bookState):
                    if let value = bookState.selectedBook {
                        state.bookState = .normal(value.name)
                        state.currentLedgerID = value.id
                        preferences.set(value.id, forKey: "currentBook")
                        return .send(.delegate(.didSelectLedger(value)))
                    }
                default:
                    break
                }
                return .none

            case .delegate:
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
