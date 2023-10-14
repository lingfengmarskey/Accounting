//
//  AccountBookConfigView.swift
//
//
//  Created by Marcos Meng on 2023/10/06.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import UIComponents

public struct AccountBookConfigView: View {
    let store: StoreOf<AccountBookConfigStore>

    private var gridItems: [GridItem] = [GridItem(.adaptive(minimum: 50), spacing: 10)]

    public init(_ store: StoreOf<AccountBookConfigStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Account Name")
                            .font(.headline)
                        TextField("Name Your Account Book", text: viewStore.$name)
                            .textFieldStyle(.roundedBorder)
                        Text("Participators")
                            .font(.headline)
                        LazyVGrid(columns: gridItems) {
                            ForEach(0 ... viewStore.paticipators.count, id: \.self) {
                                let model = $0 == viewStore.paticipators.count ? nil : viewStore.paticipators[$0]
                                ParticipatorView(user: model) { user in
                                    viewStore.send(.tapUser(user?.id))
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                .navigationTitle("Account Book")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewStore.send(.tapTopCancel)
                        }, label: {
                            Text("Cancel")
                        })
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            viewStore.send(.tapTopDone)
                        }, label: {
                            Text("Done")
                        })
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct AccountBookConfigView_Previews: PreviewProvider {
    static var previews: some View {
        AccountBookConfigView(
            Store(
                initialState: AccountBookConfigStore.State(),
                reducer: {
                    AccountBookConfigStore()
                }
            )
        )
    }
}
