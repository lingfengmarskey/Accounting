//
//  BillslistView.swift
//
//
//  Created by Marcos Meng on 2022/08/22.
//

import ComposableArchitecture
import Core
import Foundation
import SwiftUI
import UIComponents

public struct BillslistView: View {
    let store: StoreOf<BillslistStore>

    public init(_ store: StoreOf<BillslistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
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
        }
    }

    func listView(viewStore: ViewStore<BillslistStore.State, BillslistStore.Action>) -> some View {
        List(viewStore.bills, id: \.id) { bill in
            Section {
                ForEach(bill.cells) { tup in
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(tup.type == .income ? "+" : "-")
                                Text(String(format: "%.2f", tup.value))
                                Spacer()
                            }
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(tup.type == .income ? Color.green : Color.red)
                            Text(tup.updatedAt)
                                .font(.footnote)
                                .fontWeight(.ultraLight)
                        }
                        Spacer()
                        Text(tup.mainCategory.name.firstValue)
                            .fontWeight(.bold)
                            .frame(width: 40, height: 40)
                            .background(Color.mint)
                            .clipShape(Circle())
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
