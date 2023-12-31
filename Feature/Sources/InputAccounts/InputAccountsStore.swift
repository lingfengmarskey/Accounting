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
import Domain
import SwiftUI

public struct InputAccountsStore: Reducer {
    public struct State: Equatable {
        // payment or income or others in the futrue.
        var title: String
        var inputValue: String
        var lastInput: AccountInput?
        var tapPlus: Bool
        var billsType: [BillType]
        var selectedBillType: BillType

        public init(title: String = "Payment", inputValue: String = "0.00", lastInput: AccountInput? = nil, tapPlus: Bool = false, billsType: [BillType] = [.income, .payment], selectedBillType: BillType = .payment) {
            self.title = title
            self.inputValue = inputValue
            self.lastInput = lastInput
            self.tapPlus = tapPlus
            self.billsType = billsType
            self.selectedBillType = selectedBillType
        }
//        public init(
//        ) {}
    }

    public enum Action: Equatable {
        case onAppear
        case tapClose
        case billsType(BillType)
        case setInputValue(String)
        case input(AccountInput)
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
            case .billsType(let value):
                state.selectedBillType = value
                return .none
            case .input(let value):
                // has last input
                if let lastInput = state.lastInput {
                    guard state.inputValue.count < 9 else {
                        // abandon input value, disinputable
                        return .none
                    }
                    
                    switch lastInput.type {
                    case .symbols:
                        print("symbols")
                        
                        
                        
                    case .numbers:
                        // if it's zero replace it
                        if state.inputValue.hasPrefix("0") {
                            state.inputValue = value.text
                        } else {
                            // append it
                            state.inputValue += value.text
                        }
                        return setLastInput(state: &state, value: value)
                    }
                }
                // has not last input
                switch value.type {
                case .symbols:
                    return .none
                case .numbers:
                    state.inputValue = value.text
                    return setLastInput(state: &state, value: value)
                }
            default:
                return .none
            }
        }
    }

    func setLastInput(state: inout State, value: AccountInput?) -> Effect<Action> {
        state.lastInput = value
        return .none
      }
}

extension BillType {
    var icon: Image {
        switch self {
        case .income:
                .incomeTypeImage
        case .payment:
                .paymentTypeImage
        }
    }
}
