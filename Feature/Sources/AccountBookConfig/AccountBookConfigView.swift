//
//  AccountBookConfigView.swift
//
//
//  Created by Marcos Meng on 2023/10/06.
//

import ComposableArchitecture
import Foundation
import ParticipatorDetail
import SwiftUI
import UIComponents
import Core
import Domain

public struct AccountBookConfigView: View {
    @Perception.Bindable var store: StoreOf<AccountBookConfigStore>

    private var gridItems: [GridItem] = [GridItem(.adaptive(minimum: 50), spacing: 10)]

    public init(_ store: StoreOf<AccountBookConfigStore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            scrollView
            .navigationTitle("Account Book")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.tapTopCancel)
                    }, label: {
                        Text("Cancel")
                    })
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        store.send(.tapTopDone)
                    }, label: {
                        Text("Save")
                    })
                    .disabled(store.saveDisable)
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.participatorDetail, action: \.destination.participatorDetail)
            ) { store in
                ParticipatorDetailView(store)
            }
            //                .sheet(isPresented: viewStore.$shouldShared) {
            //                    // make icloudSharedController
            //                }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
    
    var scrollView: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Account Name")
                    .font(.headline)
                TextField("Name Your Account Book", text: $store.name)
                    .textFieldStyle(.roundedBorder)
                
                
                Group {
                    Text("Participators")
                        .font(.headline)
                    LazyVGrid(columns: gridItems) {
                        ForEach(0 ... store.paticipators.count, id: \.self) {
                            let model = $0 == store.paticipators.count ? nil : store.paticipators[$0]
                            ParticipatorView(user: model) { user in
                                store.send(.tapUser(user?.id))
                            }
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
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
