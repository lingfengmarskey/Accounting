//
//  SettingView.swift
//
//
//  Created by Marcos Meng on 2022/08/22.
//

import AccountBookList
import ComposableArchitecture
import Foundation
import SwiftUI

public struct SettingView: View {
    let store: StoreOf<SettingStore>

    public init(_ store: StoreOf<SettingStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    HStack {
                        Text("当前账本")
                        Spacer()
                        Button {
                            viewStore.send(.tapBook)
                        } label: {
                            Text(viewStore.state.bookState.text)
                        }
                    }
                }
                .navigationTitle("Setting")
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /SettingStore.Destination.State.selectBook,
                    action: SettingStore.Destination.Action.selectBook
                ) { store in
                    AccountBookListView(store)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(Store(
            initialState: SettingStore.State(
                bookState: .notChoosen),
            reducer: { SettingStore() }
        ))
    }
}
