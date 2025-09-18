//
//  CategoriesView.swift
//  
//
//  Created by Marcos Meng on 2023/12/31.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Core
import UIComponents

public struct CategoriesView: View {
    let store: StoreOf<CategoriesStore>

    public init(_ store: StoreOf<CategoriesStore>) {
        self.store = store
    }
    
    let items: [GridItem] = [
        GridItem(.flexible(maximum: .infinity), spacing: 15),
        GridItem(.flexible(maximum: .infinity), spacing: 15),
    ]

    public var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: items,
                          alignment: .leading,
                          spacing: 15,
                          content: {
                    ForEach(0..<store.categories.count, id: \.self) { idx in
                        Button(action: {
                            store.send(.onTap(store.categories[idx]))
                        }, label: {
                            HStack {
                                // TODO: add real icon
                                Image.foodIcon
                                    .renderingMode(.template)
                                // TODO: updated title
                                Text("\(store.categories[idx].name)")
                                    .font(.system(size: 32, weight: .bold))
                                Spacer()
                            }
                            .foregroundStyle(store.selectedCategory == store.categories[idx] ? Color.white : Color.black)
                            .padding()
                            .frame(height: 80)
                            .background(store.selectedCategory == store.categories[idx] ? Color.flatGreen : Color.lightGray)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                        })
                    }
                })
                .padding()
            }
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
            store.send(.onAppear)
        })
        
        
    }
}


#Preview {
    CategoriesView(
        Store(initialState: CategoriesStore.State(categories: .stub()), reducer: {
            CategoriesStore()
        })
    )
}
