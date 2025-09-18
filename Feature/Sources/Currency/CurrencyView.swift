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
        
        NavigationStack {
            ScrollView {
                if store.isLoading && store.currencies.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }

                LazyVGrid(columns: items,
                          alignment: .leading,
                          spacing: 10,
                          content: {
                    ForEach(0..<store.currencies.count, id: \.self) { idx in
                        Button(action: {
                            store.send(.onTap(store.currencies[idx]))
                        }, label: {
                            HStack(spacing: 20) {
                                Text("\(store.currencies[idx].shortName.firstValue)")
                                    .font(.system(size: 20, weight: .bold))

                                Text("\(store.currencies[idx].fullName)")
                                    .font(.system(size: 20, weight: .bold))
                                Spacer()
                            }
                            .foregroundStyle(store.selectedCurrency == store.currencies[idx] ? Color.white : Color.black)
                            .padding()
                            .background(store.selectedCurrency == store.currencies[idx] ? Color.flatGreen : Color.lightGray)
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
                        //                            store.send(.tapSetting)
                    }, label: {
                        Image(systemName: "book.closed.fill")
                    })
                }
            })
        }
        .onAppear(perform: {
            store.send(.onAppear)
        })
        .alert(store: store.scope(state: \.$alert, action: \.alert))
    }
}


#Preview {
    let currencies = [CurrencyModel].stub()
    return CurrencyView(
        Store(initialState: CurrencyStore.State(currencies: currencies, selectedCurrency: currencies.first)) {
            CurrencyStore()
        } withDependencies: {
            $0.currencyClient = .stub
        }
    )
}
