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
                        Text("Name")
                    }
                    VStack(alignment: .leading) {
                        Text("Contact")
                        Text("XXX@xxx.xx")
                    }
                }
                Section {
                    
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
