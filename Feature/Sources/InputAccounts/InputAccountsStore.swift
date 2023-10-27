//
//  InputAccountsStore.swift
//
//
//  Created by Marcos Meng on 2023/10/21.
//

import ComposableArchitecture
import Core
import Foundation
import UIComponents

public struct InputAccountsStore: Reducer {
    public struct State: Equatable {
        // payment or income or others in the futrue.
        var title: String = "Payment"
        var inputValue: String = "0"
        public init() {}
    }

    public enum Action: Equatable {
        case onAppear
        case tapClose
        case setInputValue(String)
        case input(AccountsInputKeyboard.Input)
//        case binding(BindingAction<State>)
    }

    @Dependency(\.dismiss) var dismiss

    public init() {}

    public var body: some Reducer<State, Action> {
//        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .tapClose:
                return .run { _ in
                    await self.dismiss()
                }
            case .input(let value):
                // TODO: complete here
                state.inputValue.append(value.text)
                return .none
            default:
                return .none
            }
        }
    }
}
