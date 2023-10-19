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

public struct BillslistView: View {
    let store: StoreOf<BillslistStore>

    public init(_ store: StoreOf<BillslistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            Text("book list view")
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
