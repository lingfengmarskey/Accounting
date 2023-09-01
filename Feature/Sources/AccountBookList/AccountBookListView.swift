//
//  AccountBookListView.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//

import Foundation
import SwiftUI
import UIComponents
import ComposableArchitecture

public struct AccountBookListView: View {

    let store: StoreOf<AccountBooklistStore>
    
    public init(_ store: StoreOf<AccountBooklistStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                List(viewStore.state.books) {
                    BookView(title: $0.name, owner: $0.owner.name)
                }
                .listStyle(.plain)
                VStack {
                    Spacer()
                    Button {
                        viewStore.send(.addBook)
                    } label: {
                        Image(systemName: "plus")
                            .renderingMode(.some(.template))
                            .foregroundColor(.white)
                            .frame(width: 22, height: 22)
                            .padding(8)
                            .background(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                    .padding(10)
                    .background(Color.black)
                    .cornerRadius(25)
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AccountBooklistView_Previews: PreviewProvider {
    static var previews: some View {
        AccountBookListView(
            Store(
                initialState: AccountBooklistStore.State(),
                reducer: {
//                    AccountBooklistStore()
                })
        )
    }
}
