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
        NavigationView {
            List {
                Section(header: Text("当前账本")) {
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
                
                Section(header: Text("账单")) {
                    NavigationLink("账单分类") {
                        CategorySelectionView(
                            store: Store(
                                initialState: CategorySelectionStore.State(),
                                reducer: {
                                    CategorySelectionStore()
                                }
                            )
                        )
                    }
                }
            }
            .navigationTitle("设置")
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
