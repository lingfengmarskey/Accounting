//
//  CategoriesView.swift
//  
//
//  Created by Marcos Meng on 2023/12/31.
//

import Foundation
import SwiftUI
import ComposableArchitecture

public struct CategoriesView: View {
    let store: StoreOf<CategoriesStore>

    public init(_ store: StoreOf<CategoriesStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                List(content: {
                    
                })
                .navigationTitle("大分類")
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
//                            viewStore.send(.tapSetting)
                        }, label: {
                            Image(systemName: "book.closed.fill")
                        })
                    }
                })
            }
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }
}


#Preview {
    CategoriesView(
        Store(initialState: CategoriesStore.State(), reducer: {
            CategoriesStore()
        })
    )
}
