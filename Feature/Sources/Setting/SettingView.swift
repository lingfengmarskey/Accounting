//
//  SettingView.swift
//
//
//  Created by Marcos Meng on 2022/08/22.
//

import ComposableArchitecture
import Foundation
import SwiftUI

public struct SettingView: View {
    let store: Store<SettingStore.State, SettingStore.Action>

    public init(store: Store<SettingStore.State, SettingStore.Action>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack {
                    Text("当前账本")
                    Spacer()
                    Button {
                        viewStore.send(.tapBook)
                    } label: {
                        Text(viewStore.state.bookState.text)
                    }
                }
                Spacer()
            }
            .padding()
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView(store: .init(
            initialState: .init(bookState: .notChoosen),
            reducer: SettingStore.reducer,
            environment: .live
        ))
    }
}
