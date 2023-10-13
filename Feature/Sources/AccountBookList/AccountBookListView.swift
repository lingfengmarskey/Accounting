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

    @State private var path = NavigationPath()

    public init(_ store: StoreOf<AccountBooklistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack(path: $path) {
                ZStack {
                    List {
                        ForEach(viewStore.books) {
                            BookView(
                                title: $0.name,
                                owner: $0.owner.name,
                                id: $0.id,
                                selectedId: viewStore.$selected,
                                onTapDetail: {
                                    //TODO: selected one will be in edit page by present
                                    path.append("config")
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

                        } onAdd: {
                            viewStore.send(.addBook)
                            path.append("config")
                        }
                    }
                    .disabled(mode.isEditing ? false : viewStore.saveDisable)
                }
                .navigationDestination(for: String.self, destination: { view in
                    if view == "config" {
                        AccountBookConfigView(self.store.scope(state: \.accountBookConfig, action: AccountBooklistStore.Action.accountBookConfig))
                    }
                })
                .navigationTitle("Account Books")
                .toolbar {
                    EditButton()
                }
                .environment(\.editMode, $mode)
            }
            .onAppear {
                viewStore.send(.onAppear)
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
