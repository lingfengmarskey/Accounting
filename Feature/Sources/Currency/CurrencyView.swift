//
//  CurrencyView.swift
//
//
//  Created by Marcos Meng on 2024/01/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Core
import UIComponents

public struct CurrencyView: View {
    
    
    let store: StoreOf<CurrencyStore>

    public init(_ store: StoreOf<CurrencyStore>) {
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
                        ForEach(0..<viewStore.currencies.count, id: \.self) { idx in
                            Button(action: {
                                viewStore.send(.onTap(viewStore.currencies[idx]))
                            }, label: {
                                HStack(spacing: 20) {
                                    Text("\(viewStore.currencies[idx].shortName.firstValue)")
                                        .font(.system(size: 20, weight: .bold))
                                    
                                    Text("\(viewStore.currencies[idx].fullName)")
                                        .font(.system(size: 20, weight: .bold))
                                    Spacer()
                                }
                                .foregroundStyle(viewStore.selectedCurrency == viewStore.currencies[idx] ? Color.white : Color.black)
                                .padding()
                                .background(viewStore.selectedCurrency == viewStore.currencies[idx] ? Color.flatGreen : Color.lightGray)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                            })
                        }
                    })
                    .padding()
                }
                .navigationTitle("通貨")
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
    CurrencyView(
        Store(initialState: CurrencyStore.State(), reducer: {
            CurrencyStore()
        })
    )
}
