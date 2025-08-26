//
//  BillslistView.swift
//
//
//  Created by Marcos Meng on 2022/08/22.
//

import BillDetail
import ComposableArchitecture
import Core
import Foundation
import InputAccounts
import Setting
import SwiftUI
import UIComponents

public struct BillslistView: View {
    @Perception.Bindable var store: StoreOf<BillslistStore>

    public init(_ store: StoreOf<BillslistStore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                listView
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        XButton {
                            store.send(.tapAdd(nil))
                        } onPlus: {
                            store.send(.tapAdd(.income))
                        } onMinus: {
                            store.send(.tapAdd(.payment))
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Bills")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        store.send(.tapSetting)
                    }, label: {
                        Image(systemName: "book.closed.fill")
                    })
                }
            })
            .navigationDestination(
                item: $store.scope(state: \.destination?.billDetail, action: \.destination.billDetail)
            ) { store in
                BillDetailView(store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.setting, action: \.destination.setting)
            ) { store in
                SettingView(store)
            }
            .fullScreenCover(
                item: $store.scope(state: \.destination?.addAccounts, action: \.destination.addAccounts)
            ) { store in
                InputAccountsView(store)
            }
        }
        .onAppear(perform: {
            store.send(.onAppear)
        })
    }

    var listView: some View {
        List(store.bills, id: \.id) { bill in
            Section {
                ForEach(bill.cells) { tup in
                    BillSingleView(
                        isIncome: tup.type == .income,
                        value: tup.value,
                        updatedAt: tup.updatedAt,
                        mainCategory: tup.mainCategory.name.firstValue
                    )
                    .onTapGesture {
                        store.send(.onTap(tup))
                    }
                }
            } header: {
                Text(bill.header ?? "")
                    .font(.title3)
                    .fontWeight(.black)
            }
        }
    }
}

#Preview {
    BillslistView(
        Store(initialState: BillslistStore.State(), reducer: {
            BillslistStore()
        })
    )
}
