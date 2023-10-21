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

public struct SettingStore: Reducer {
    public struct State: Equatable {
        var bookState: BookState = .notChoosen

        @PresentationState var destination: Destination.State?

        public init(
            bookState: BookState = .notChoosen
        ) {
            self.bookState = bookState
        }
    }

    public enum Action: Equatable {
        case tapBook
        case none
        case onAppear
//        case selectBook(AccountBooklistStore.Action)
        case destination(PresentationAction<Destination.Action>)
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

    public struct Destination: Reducer {
        public enum State: Equatable {
            case selectBook(AccountBooklistStore.State)
        }

        public enum Action: Equatable {
            case selectBook(AccountBooklistStore.Action)
        }

        public var body: some Reducer<State, Action> {
            Scope(state: /State.selectBook, action: /Action.selectBook) {
                AccountBooklistStore()
            }
        }
    }

    @Dependency(\.preferences) var preferences
    // TODO: depedency config
    public init() {}

    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: find model from local store.
                if let currentBookId = preferences.value(forKey: "currentBook") as? String {
                    // check current book id is validate
                    // find AccountBookModel from bookId
                } else {
                    state.bookState = .notChoosen
                }
                return .none
            case .tapBook:
                // TODO: check route
                // Mock:
                state.destination = .selectBook(.init())
                return .none
            case .destination(.presented(.selectBook(.selectDone))):
                switch state.destination {
                case let .selectBook(bookState):
                    if let value = bookState.selectedBook {
                        state.bookState = .normal(value.name)
                    }
                default:
                    break
                }
                return .none

            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}
