//
//  ViewModel.swift
//
//
//  Created by Marcos Meng on 2022/08/04.
//

import AccountBookConfig
import ComposableArchitecture
import Core
import Foundation

@Reducer
public struct AccountBooklistStore {
    @ObservableState
    public struct State {
        var books: [AccountBook]
        var saveDisable: Bool

        public var selectedBook: AccountBook? {
            if let book = books.first(where: { selected == $0.id }) {
                return book
            }
            return nil
        }

        var selected: String?

        var accountBookConfig: AccountBookConfigStore.State

        var isShouldPresent = false

        public init(books: [AccountBook] = [],
                    saveDisable: Bool = true,
                    selected: String? = nil,
                    accountBookConfig: AccountBookConfigStore.State = .init(),
                    isShouldPresent: Bool = false
        ) {
            self.books = books
            self.saveDisable = saveDisable
            self.selected = selected
            self.accountBookConfig = accountBookConfig
            self.isShouldPresent = isShouldPresent
        }
    }

    public enum Action: BindableAction {
        case onAppear
        case toTop
        case addBook
        case selectDone
        case tapDetail(bookID: String)
        case setPresent(Bool)
        case removeItem(IndexSet)
        case booksResponse([AccountBook])
        case binding(BindingAction<State>)
        case accountBookConfig(AccountBookConfigStore.Action)
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.ledgerClient) var ledgerClient

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.booksResponse(await ledgerClient.fetchLedgers()))
                }
            case .addBook:
                state.accountBookConfig = .init()
                return .run { send in
                    await send(.setPresent(true))
                }
            case let .tapDetail(bookID: id):
                if let book = state.books.first(where: { $0.id == id }) {
                    state.accountBookConfig.book = book
                    return .run { send in
                        await send(.setPresent(true))
                    }
                }
                return .none
            case let .setPresent(value):
                state.isShouldPresent = value
                return .none
            case .selectDone:
                // TODO:
//                return .none
                return .run { _ in await self.dismiss() }
            case let .removeItem(index):
                // TODO: remove item
                state.selected = nil
                state.saveDisable = true
                state.books.remove(atOffsets: index)
                return .none
            case let .booksResponse(books):
                state.books = books
                if let selected = state.selected, !books.contains(where: { $0.id == selected }) {
                    state.selected = nil
                    state.saveDisable = true
                } else {
                    state.saveDisable = state.selected == nil
                }
                return .none
//            case .binding(let $dd):
////                
////                state.saveDisable = state.selected == nil
//                return .none
            case .binding:
                return .none
            case .accountBookConfig(.tapTopCancel):
                return .none
            case .accountBookConfig(.cancelConfirmed):
                state.isShouldPresent = false
                state.accountBookConfig = .init()
                return .none
            case .accountBookConfig(.saveResponse(.success)):
                state.isShouldPresent = false
                state.accountBookConfig = .init()
                return .run { send in
                    await send(.booksResponse(await ledgerClient.fetchLedgers()))
                }
            case .accountBookConfig(.saveResponse(.failure)):
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.accountBookConfig, action: \.accountBookConfig) {
            AccountBookConfigStore()
        }
//        .ifLet(\.accountBookConfig, action: /Action.accountBookConfig) {
//            AccountBookConfigStore()
//        }
    }
}

