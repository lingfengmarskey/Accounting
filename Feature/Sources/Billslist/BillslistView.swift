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
import SwiftUI
import UIComponents
import Setting

public struct BillslistView: View {
    let store: StoreOf<BillslistStore>

    public init(_ store: StoreOf<BillslistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ZStack {
                    listView(viewStore: viewStore)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            XButton {
                                viewStore.send(.tapAdd(nil))
                            } onPlus: {
                                viewStore.send(.tapAdd(.income))
                            } onMinus: {
                                viewStore.send(.tapAdd(.payment))
                            }
                            .padding()
                        }
                    }
                }
                .navigationTitle("Bills")
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStore.send(.tapSetting)
                        }, label: {
                            Image(systemName: "book.closed.fill")
                                .renderingMode(.template)
                                .foregroundStyle(Color.black)
                        })
                    }
                })
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) } ),
                    state: /BillslistStore.Destination.State.billDetail,
                    action: BillslistStore.Destination.Action.billDetail
                ) { store in
                    BillDetailView(store)
                }
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) } ),
                    state: /BillslistStore.Destination.State.setting,
                    action: BillslistStore.Destination.Action.setting
                ) { store in
                    SettingView(store)
                }
                
            }
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }

    func listView(viewStore: ViewStore<BillslistStore.State, BillslistStore.Action>) -> some View {
        List(viewStore.bills, id: \.id) { bill in
            Section {
                ForEach(bill.cells) { tup in
                    BillSingleView(
                        isIncome: tup.type == .income,
                        value: tup.value,
                        updatedAt: tup.updatedAt,
                        mainCategory: tup.mainCategory.name.firstValue
                    )
                    .onTapGesture {
                        viewStore.send(.onTap(tup))
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
