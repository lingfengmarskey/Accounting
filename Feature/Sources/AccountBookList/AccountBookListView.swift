//
//  AccountBookListView.swift
//
//
//  Created by Marcos Meng on 2022/08/04.
//

import AccountBookConfig
import ComposableArchitecture
import Foundation
import SwiftUI
import UIComponents

public struct AccountBookListView: View {
    let store: StoreOf<AccountBooklistStore>

    @State var mode: EditMode = .inactive

    public init(_ store: StoreOf<AccountBooklistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    List {
                        ForEach(viewStore.books) {
                            BookView(
                                title: $0.name,
                                owner: $0.owner.name,
                                id: $0.id,
                                selectedId: viewStore.$selected,
                                onTapDetail: { id in
                                    viewStore.send(.tapDetail(bookID: id))
                                }
                            )
                        }
                        .onDelete { index in
                            viewStore.send(.removeItem(index))
                        }
                    }
                    .listStyle(.plain)
                    VStack {
                        Spacer()
                        FooterButton {
                            viewStore.send(.selectDone)
                        } onAdd: {
                            viewStore.send(.addBook)
                        }
                    }
                    .disabled(mode.isEditing ? false : viewStore.saveDisable)
                }
                .navigationTitle("Account Books")
                .toolbar {
                    EditButton()
                }
                .environment(\.editMode, $mode)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
            .sheet(isPresented: viewStore.binding(
                get: \.isShouldPresent,
                send: AccountBooklistStore.Action.setPresent
            )) {
                AccountBookConfigView(
                    self.store.scope(
                        state: \.accountBookConfig,
                        action: AccountBooklistStore.Action.accountBookConfig
                    )
                )
            }
        }
    }
}

struct AccountBooklistView_Previews: PreviewProvider {
    static var previews: some View {
        AccountBookListView(
            Store(
                initialState: AccountBooklistStore.State(),
                reducer: {
                    AccountBooklistStore()
                }
            )
        )
    }
}
