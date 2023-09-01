//
//  RecordBookApp.swift
//  RecordBook
//
//  Created by Marcos Meng on 2022/07/23.
//

import SwiftUI
import Root
import ComposableArchitecture

@main
struct RecordBookApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                Store(
                    initialState: RootStore.State(),
                    reducer: {
                        RootStore()
                            .signpost()
                            ._printChanges()
                    })
            )
        }
    }
}
