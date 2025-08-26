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
    @Perception.Bindable var store: StoreOf<AccountBooklistStore>

    @State var mode: EditMode = .inactive

    public init(_ store: StoreOf<AccountBooklistStore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                listView
                VStack {
                    Spacer()
                    FooterButton {
                        store.send(.selectDone)
                    } onAdd: {
                        store.send(.addBook)
                    }
                }
                .disabled(mode.isEditing ? false : store.saveDisable)
            }
            .navigationTitle("Account Books")
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $mode)
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.isShouldPresent.sending(\.setPresent)) {
            AccountBookConfigView(
                self.store.scope(
                    state: \.accountBookConfig,
                    action: \.accountBookConfig
                )
            )
        }
    }
    
    public var listView: some View {
        List {
            ForEach(store.books) {
                BookView(
                    title: $0.name,
                    owner: $0.owner.name,
                    id: $0.id,
                    selectedId: $store.selected,
                    onTapDetail: { id in
                        store.send(.tapDetail(bookID: id))
                    }
                )
            }
            .onDelete { index in
                store.send(.removeItem(index))
            }
        }
        .listStyle(.plain)
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
