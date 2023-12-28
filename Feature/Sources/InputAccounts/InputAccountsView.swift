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
                VStack(spacing: 0) {
                    // display
                    Group {
                        HStack {
                            Text(viewStore.inputValue)
                                .font(.system(size: 48, weight: .bold))
                            Spacer()
                        }
                    }
                    // currency
                    Group {
                        HStack {
                            Button(action: {}, label: {
                                HStack {
                                    Text("USD")
                                        .font(.system(size: 20, weight: .bold))
                                    Image(systemName: "chevron.down")
                                }
                                .foregroundStyle(Color.black)
                            })
                            Spacer()
                        }
                    }
                    .padding(.bottom, 13)
                    // category
                    Group {
                        AccountCategoriesView()
                    }
                    // asist buttons
                    Spacer()
                    Group {
                        HStack {
                            AsistButton(title: "Date") {
                                
                            }
                            AsistButton(title: "Type") {
                                
                            }
                            AsistButton(title: "Note") {
                                
                            }
                        }
                    }
                    .padding(.bottom, 3)
                    // input numbers
//                    Group {
//                        AccountsInputKeyboard { value in
//                            viewStore.send(.input(value))
//                        }
//                    }
                }
                .padding(.leading, 25)
                .padding(.trailing, 25)
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


struct AsistButton: View {
    let title: String
    let onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    Color.green
                }
                .clipShape(RoundedRectangle(cornerRadius: 5))
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
