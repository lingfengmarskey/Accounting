//
//  AccountBookListView.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//

import Foundation
import SwiftUI
import UIComponents
import ComposableArchitecture

public struct AccountBookListView: View {

    let store: StoreOf<AccountBooklistStore>
    
    public init(_ store: StoreOf<AccountBooklistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
                    List {
                        ForEach(viewStore.books) {
                            BookView(
                                title: $0.name,
                                owner: $0.owner.name,
                                id: $0.id,
                                selectedId: viewStore.$selected
                            )
                        }
                        .onDelete { index in
                            viewStore.send(.removeItem(index))
                        }
                    }
                    .listStyle(.insetGrouped)
                    VStack {
                        Spacer()
                        PlusButton(disable: viewStore.saveDisable) {
                            viewStore.send(.addBook)
                        }
                    }
                }
                .navigationTitle("Account Books")
                .toolbar {
                    EditButton()
                }
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
                })
        )
    }
}
