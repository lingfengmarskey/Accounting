//
//  SubCategoriesView.swift
//  
//
//  Created by Marcos Meng on 2024/01/07.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Core
import UIComponents

public struct SubCategoriesView: View {
    
    
    let store: StoreOf<SubCategoriesStore>

    public init(_ store: StoreOf<SubCategoriesStore>) {
        self.store = store
    }
    
    let items: [GridItem] = [
        GridItem(.flexible(maximum: .infinity), spacing: 15),
    ]

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: items,
                              alignment: .leading,
                              spacing: 10,
                              content: {
                        ForEach(0..<viewStore.subCategories.count, id: \.self) { idx in
                            Button(action: {
                                viewStore.send(.onTap(viewStore.subCategories[idx]))
                            }, label: {
                                HStack {
                                    // TODO: add real icon
                                    Image.foodIcon
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    // TODO: updated title
                                    Text("\(viewStore.subCategories[idx].name.firstValue)")
                                        .font(.system(size: 20, weight: .bold))
                                    Spacer()
                                }
                                .foregroundStyle(viewStore.selectedSubCategory == viewStore.subCategories[idx] ? Color.white : Color.black)
                                .padding()
                                .background(viewStore.selectedSubCategory == viewStore.subCategories[idx] ? Color.flatGreen : Color.lightGray)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                            })
                        }
                    })
                    .padding()
                }
                .navigationTitle("小分類")
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
    SubCategoriesView(
        Store(initialState: SubCategoriesStore.State(), reducer: {
            SubCategoriesStore()
        })
    )
}
