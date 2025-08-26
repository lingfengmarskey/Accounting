//
//  BillDetailView.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import ComposableArchitecture
import Core
import Foundation
import SwiftUI

public struct BillDetailView: View {
    let store: StoreOf<BillDetailStore>

    public init(_ store: StoreOf<BillDetailStore>) {
        self.store = store
    }

    public var body: some View {
        
        List {
            Spacer()
                .frame(height: 50)
            HStack {
                Spacer()
                Text(store.billModel.type == .income ? "+" : "-")
                Text(String(format: "%.2f", store.billModel.value))
                Spacer()
            }
            .font(.largeTitle)
            .fontWeight(.heavy)
            .foregroundStyle(store.billModel.type == .income ? Color.blue : .red)
            .listRowSeparator(.hidden)
            Spacer()
                .frame(height: 80)
            detail(title: "MainCategory", content: store.billModel.mainCategory.name)
            detail(title: "createdByUser", content: store.billModel.createdByUser.name)
            detail(title: "createdAt", content: store.billModel.createdAt)
            detail(title: "updatedByUser", content: store.billModel.updatedByUser.name)
            detail(title: "updatedAt", content: store.billModel.updatedAt)
            detail(title: "subCategory", content: store.billModel.subCategory.name)
            detail(title: "description", content: store.billModel.description)
        }
        .listStyle(.plain)
        .navigationTitle("Bill Detail")
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    store.send(.edit)
                } label: {
                    Text("Edit")
                }
            }
        })
        
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
