//
//  InputAccountsStore.swift
//
//
//  Created by Marcos Meng on 2023/10/21.
//

import ComposableArchitecture
import Core
import Foundation

public struct InputAccountsStore: Reducer {
    public struct State: Equatable {
        // payment or income or others in the futrue.
        var title: String = "Payment"
        @BindingState var inputValue: String?
        public init() {}
    }

    public enum Action: Equatable, BindableAction {
        case onAppear
        case tapClose
        case setInputValue(String)
        case binding(BindingAction<State>)
    }

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { _, action in
            switch action {
            case .onAppear:
                return .none
            case .tapClose:
                return .run { _ in
                    await self.dismiss()
                }
            default:
                return .none
            }
        }
    }
}
