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

    let store: StoreOf<ParticipatorDetaolStore>

    public init(_ store: StoreOf<ParticipatorDetaolStore>) {
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
                        isSelected: viewStore.$isReadOnly
                    ) {
                        viewStore.send(.tapReadOnly)
                    }
                    SingleSelectView(
                        title: "Read & Write",
                        isSelected: viewStore.$isReadWrite
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
        }
    }
}

#Preview {
    ParticipatorDetailView(
        Store(initialState: ParticipatorDetaolStore.State.init(participator: .stub()), reducer: {
            ParticipatorDetaolStore()
        })
    )
}
