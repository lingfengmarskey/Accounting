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
import Categories
import SubCategories

public struct InputAccountsView: View {
    let store: StoreOf<InputAccountsStore>

    public init(_ store: StoreOf<InputAccountsStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 15) {
                        
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
                        // type
                        ScrollView(
                            .horizontal,
                            showsIndicators: false) {
                                LazyHStack(spacing: 20) {
                                    ForEach(viewStore.billsType, id: \.self) { value in
                                        
                                        Button {
                                            viewStore.send(.billsType(value))
                                        } label: {
                                            HStack {
                                                value.icon
                                                    .renderingMode(.template)
                                                Text(value.title)
                                                    .font(.system(size: 20, weight: .bold))
                                            }
                                            .padding()
                                        }
                                        .foregroundStyle(viewStore.selectedBillType == value ? Color.white : Color.black)
                                        .background(viewStore.selectedBillType == value ? Color.flatGreen : Color.lightGray)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .frame(height: 50)
                        
                        // big category
                        Group {
                            HStack {
                                Button {
                                    // TODO: add real params.
                                    viewStore.send(.tapBigCategory(nil))
                                } label: {
                                    HStack {
                                        VStack {
                                            Text("大分類")
                                                .font(.system(size: 20))
                                            Spacer()
                                        }
                                        .padding(.top, 15)
                                        .padding(.leading, 15)
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .frame(width: 28)
                                    }
                                }
                                .frame(width: 150, height: 90)
                                .background(Color.lightGray)
                                .foregroundStyle(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                        }
                        // sub category
                        Group {
                            HStack {
                                Button {
                                    // TODO: add real params.
                                    viewStore.send(.tapSubCategory(nil))
                                } label: {
                                    HStack {
                                        VStack {
                                            Text("小分類")
                                                .font(.system(size: 20))
                                            Spacer()
                                        }
                                        .padding(.top, 15)
                                        .padding(.leading, 15)
                                        Spacer()
                                        Image(systemName: "chevron.forward")
                                            .frame(width: 28)
                                    }
                                }
                                .frame(width: 200, height: 65)
                                .background(Color.lightGray)
                                .foregroundStyle(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                Spacer()
                            }
                        }
                        // Date
                        Group {
                            HStack {
                                Button {
                                    
                                } label: {
                                    HStack(alignment: .center) {
                                        Text("時間")
                                            .font(.system(size: 20))
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                }
                                .frame(height: 50)
                                .background(Color.lightGray)
                                .foregroundStyle(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        // photoes
                        Group {
                            HStack {
                                Button {
                                    
                                } label: {
                                    VStack {
                                        HStack(alignment: .center) {
                                            Text("写真")
                                                .font(.system(size: 20))
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                    .padding(.top, 15)
                                }
                                .frame(height: 150)
                                .background(Color.lightGray)
                                .foregroundStyle(Color.black)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        
                        // submit buttons
                        Spacer()
                        Group {
                            Button {
                                
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Record")
                                        .font(.system(size: 24, weight: .bold))
                                    Spacer()
                                }
                            }
                            .frame(height: 68)
                            .background(Color.black)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                                        
                        }
                    }
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
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /InputAccountsStore.Destination.State.selectCategory,
                    action: InputAccountsStore.Destination.Action.selectCategory
                ) { store in
                    CategoriesView(store)
                }
                .navigationDestination(
                    store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                    state: /InputAccountsStore.Destination.State.selectSubCategory,
                    action: InputAccountsStore.Destination.Action.selectSubCategory
                ) { store in
                    SubCategoriesView(store)
                }
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
