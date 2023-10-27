//
//  InputAccountsView.swift
//
//
//  Created by Marcos Meng on 2023/10/21.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import UIComponents

public struct InputAccountsView: View {
    let store: StoreOf<InputAccountsStore>

    public init(_ store: StoreOf<InputAccountsStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                VStack {
                    // display
                    Group {
                        HStack {
                            Button(action: {}, label: {
                                Text("USD")
                                    .padding()
                                    .background(Color.green)
                                    .font(.largeTitle)
                                    .fontWeight(.heavy)
                            })
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            TextFieldView(text: viewStore.$inputValue)
//                            Text(viewStore.inputValue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 40)
                                .padding()
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    // category
                    Group {}
                    // asist buttons
                    Group {}
                    // input numbers
                    Spacer()
                    Group {
                        
                    }
                }
                .padding()
                .navigationTitle(viewStore.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStore.send(.tapClose)
                        }, label: {
                            Image(systemName: "xmark")
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
    InputAccountsView(
        Store(initialState: InputAccountsStore.State(), reducer: {
            InputAccountsStore()
        })
    )
}
