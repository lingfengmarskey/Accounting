//
//  BillDetailView.swift
//
//
//  Created by Marcos Meng on 2023/10/19.
//

import ComposableArchitecture
import Foundation
import SwiftUI

public struct BillDetailView: View {
    let store: StoreOf<BillDetailStore>

    public init(_ store: StoreOf<BillDetailStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            Text("hello world")
        }
    }
}

#Preview {
    BillDetailView(
        Store(initialState: BillDetailStore.State(), reducer: {
            BillDetailStore()
        })
    )
}
