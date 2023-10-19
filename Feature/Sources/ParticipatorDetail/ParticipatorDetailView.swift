//
//  ParticipatorDetailView.swift
//
//
//  Created by Marcos Meng on 2023/10/14.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Core
import UIComponents

public struct ParticipatorDetailView: View {

    let store: StoreOf<ParticipatorDetailStore>

    public init(_ store: StoreOf<ParticipatorDetailStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(content: {
                Section {
                    HStack {
                        Image(systemName: "person.fill")
                        Text(viewStore.participatorModel.name)
                    }
                    VStack(alignment: .leading) {
                        Text("Contact")
                        Text("XXX@xxx.xx")
                    }
                }
                Section {
                    SingleSelectView(
                        title: "Read Only",
                        isSelected: viewStore.binding(get: \.isReadOnly, send: ParticipatorDetailStore.Action.setReadOnly)
                    ) {
                        viewStore.send(.tapReadOnly)
                    }
                    SingleSelectView(
                        title: "Read & Write",
                        isSelected: viewStore.binding(get: \.isReadWrite, send: ParticipatorDetailStore.Action.setReadWrite)
                    ) {
                        viewStore.send(.tapReadWrite)
                    }
                } header: {
                    Text("Authority")
                        .bold()
                }
                Section {
                    Button(action: {
                        viewStore.send(.delete)
                    }, label: {
                        HStack() {
                            Spacer()
                            Text("Delete")
                                .foregroundStyle(.red)
                            Spacer()
                        }
                    })
                }
            })
            .navigationTitle("Participator Detail")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        viewStore.send(.tapBack)
                    }, label: {
                        Image(systemName: "arrow.backward")
                    })
                }
            }
            .onAppear(perform: {
                viewStore.send(.onAppear)
            })
        }
    }
}

#Preview {
    ParticipatorDetailView(
        Store(initialState: ParticipatorDetailStore.State.init(participator: .stub()), reducer: {
            ParticipatorDetailStore()
        })
    )
}
