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
            ForEach(store.books) { book in
                rowView(
                    title: book.name,
                    id: book.id,
                    owner: book.owner.name,
                    isSelected: store.selected == book.id,
                    onTapDetail: { id in
                        store.send(.tapDetail(bookID: id))
                    }
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    // 单选：设置选中项为当前 book.id
                    store.selected = book.id
                    store.saveDisable = store.selected == nil
                }
            }
            .onDelete { index in
                store.send(.removeItem(index))
            }
        }
        .listStyle(.plain)
    }

    @Environment(\.editMode) private var editMode

    func rowView(
        title: String,
        id: String,
        owner: String,
        isSelected: Bool,
        onTapDetail: @escaping (String) -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 8) {
            if editMode?.wrappedValue.isEditing == false {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "checkmark.circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
            }
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.system(size: 20, weight: .regular, design: .serif))
                        .lineLimit(1)
                    Spacer()
                }
                Text(owner)
                    .font(.system(size: 14, weight: .ultraLight, design: .serif))
                    .foregroundColor(.black)
            }
            Spacer(minLength: 8)
            // 详情按钮（右侧）
            Button(action: { onTapDetail(id) }, label: {
                Image(systemName: "info.circle")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 4)
            })
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
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
