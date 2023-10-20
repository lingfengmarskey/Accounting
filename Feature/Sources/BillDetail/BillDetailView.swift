//
//  BillDetailView.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import Core

public struct BillDetailView: View {
    let store: StoreOf<BillDetailStore>

    public init(_ store: StoreOf<BillDetailStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                Spacer()
                    .frame(height: 50)
                HStack {
                    Spacer()
                    Text(viewStore.billModel.type == .income ? "+" : "-")
                    Text(String(format: "%.2f", viewStore.billModel.value) )
                    Spacer()
                }
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundStyle(viewStore.billModel.type == .income ? Color.blue : .red)
                .listRowSeparator(.hidden)
                Spacer()
                    .frame(height: 80)
                detail(title: "MainCategory", content: viewStore.billModel.mainCategory.name)
                detail(title: "createdByUser", content: viewStore.billModel.createdByUser.name)
                detail(title: "createdAt", content: viewStore.billModel.createdAt)
                detail(title: "updatedByUser", content: viewStore.billModel.updatedByUser.name)
                detail(title: "updatedAt", content: viewStore.billModel.updatedAt)
                detail(title: "subCategory", content: viewStore.billModel.subCategory.name)
                detail(title: "description", content: viewStore.billModel.description)
            }
            .listStyle(.plain)
            .navigationTitle("Bill Detail")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewStore.send(.edit)
                    } label: {
                        Text("Edit")
                    }

                }
            })
        }
    }

    func detail(title: String, content: String) -> some View {
        HStack {
            Text(title)
                .fontWeight(.ultraLight)
            Spacer()
            Text(content)
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    BillDetailView(
        Store(initialState: BillDetailStore.State(billModel: .stub()), reducer: {
            BillDetailStore()
        })
    )
}
