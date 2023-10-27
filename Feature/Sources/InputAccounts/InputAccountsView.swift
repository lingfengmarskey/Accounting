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
                    Spacer(minLength: 20)
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
                            Text(viewStore.inputValue)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 40)
                                .padding()
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .background(Color.red)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .padding()
                    // category
                    Group {
                        AccountCategoriesView()
                    }
                    .padding()
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
                        }.padding(EdgeInsets(top: 0, leading: 10, bottom: 5, trailing: 10))
                    }
                    
                    // input numbers
                    Group {
                        AccountsInputKeyboard { value in
                            viewStore.send(.input(value))
                        }
                    }
                }
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
