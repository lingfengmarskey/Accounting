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
    @Perception.Bindable var store: StoreOf<SettingStore>

    public init(_ store: StoreOf<SettingStore>) {
        self.store = store
    }

    public var body: some View {
        List {
            HStack {
                Text("当前账本")
                Spacer()
                Button {
                    store.send(.tapBook)
                } label: {
                    Text(store.bookState.text)
                }
            }
        }
        .navigationTitle("Setting")
        .navigationDestination(
          item: $store.scope(state: \.destination?.selectBook, action: \.destination.selectBook)
        ) { store in
            AccountBookListView(store)
        }
        .onAppear {
            store.send(.onAppear)
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
