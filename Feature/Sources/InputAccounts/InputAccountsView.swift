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
import Currency

public struct InputAccountsView: View {
    @Perception.Bindable var store: StoreOf<InputAccountsStore>

    public init(_ store: StoreOf<InputAccountsStore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            scrollView
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .navigationTitle(store.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            store.send(.tapClose)
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    }
                })
                .navigationDestination(
                    item: $store.scope(state: \.destination?.selectCategory, action: \.destination.selectCategory)
                ) { store in
                    CategoriesView(store)
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.selectSubCategory, action: \.destination.selectSubCategory)
                ) { store in
                    SubCategoriesView(store)
                }
                .navigationDestination(
                    item: $store.scope(state: \.destination?.selectCurrency, action: \.destination.selectCurrency)
                ) { store in
                    CurrencyView(store)
                }
        }
        .onAppear(perform: {
            store.send(.onAppear)
        })
        .confirmationDialog($store.scope(state: \.choosePhotoDialog, action: \.choosePhotoDialog))
    }

    var scrollView: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                // display
                Group {
                    HStack {
                        BoldTextField(
                            textValue: $store.inputValue.sending(\.textChanged),
                            placeholderText: store.state.inputPlaceholder,
                            fontSize: 48
                        ) { item in
                            store.send(.input(item))
                        }
                        .font(.system(size: 48, weight: .bold))
                        Spacer()
                    }
                }
                // currency
                Group {
                    HStack {
                        Button(action: {
                            store.send(.tapCurrency(nil))
                        }, label: {
                            HStack {
                                Text("USD") // TODO: update here to real data.
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
                            ForEach(store.billsType, id: \.self) { value in
                                
                                Button {
                                    store.send(.billsType(value))
                                } label: {
                                    HStack {
                                        value.icon
                                            .renderingMode(.template)
                                        Text(value.title)
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                    .padding()
                                }
                                .foregroundStyle(store.selectedBillType == value ? Color.white : Color.black)
                                .background(store.selectedBillType == value ? Color.flatGreen : Color.lightGray)
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                
                // big category
                Group {
                    HStack {
                        Button {
                            // TODO: add real params.
                            store.send(.tapBigCategory(nil))
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
                            store.send(.tapSubCategory(nil))
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
                        DatePicker("", selection: $store.inputDate.sending(\.dateChanged), displayedComponents: [.date, .hourAndMinute])
//                            .labelsHidden()
                        Spacer()
                    }
                }
                // photoes
                Group {
                    HStack {
                        Button {
                            store.send(.tapChoosePhoto)
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
