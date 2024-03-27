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
import Categories
import SubCategories
import Currency

public struct InputAccountsStore: Reducer {
    public struct State: Equatable {
        // payment or income or others in the futrue.
        var title: String
        var inputValue: String
        var inputDate: Date
        var inputPlaceholder: String
        var tapPlus: Bool
        var billsType: [BillType]
        var selectedBillType: BillType
        var showPhotoLib = false
        var currentOperator: Operator?
        var currentOperand: String?
        
        @PresentationState var destination: Destination.State?
        @PresentationState var choosePhotoDialog: ConfirmationDialogState<Action.ChoosePhotoDialog>?

        public init(title: String = "Payment", 
                    inputValue: String = "",
                    inputDate: Date = .now, // TODO: add date to env DI.
                    inputPlaceholder: String = "0.00",
                    tapPlus: Bool = false,
                    billsType: [BillType] = [.income, .payment],
                    selectedBillType: BillType = .payment
        ) {
            self.title = title
            self.inputValue = inputValue
            self.inputDate = inputDate
            self.tapPlus = tapPlus
            self.billsType = billsType
            self.inputPlaceholder = inputPlaceholder
            self.selectedBillType = selectedBillType
        }
    }

    public enum Operator: String, Equatable, CaseIterable {
        case add = "+"
        case subtract = "-"
        
        static var allCasesValue: Set<String> {
            ["+", "-"]
        }
    }

    public enum Action: Equatable {
        case onAppear
        case tapClose
        case textChanged(String)
        case dateChanged(Date)
        case billsType(BillType)
        case setInputValue(String)
        case tapBigCategory(BillMainCategory?)
        case tapSubCategory(BillSubCategory?)
        case tapCurrency(CurrencyModel?)
        case input(AccountInput)
//        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case tapChoosePhoto
        case choosePhotoDialog(PresentationAction<ChoosePhotoDialog>)
        public enum ChoosePhotoDialog: Equatable {
          case fromCamera
          case fromLibrary
        }
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
            case .tapBigCategory(let category):
                state.destination = .selectCategory(.init(selectedCategory: category))
                return .none
            case .tapSubCategory(let category):
                state.destination = .selectSubCategory(.init(selectedSubCategory: category))
                return .none
            case .tapCurrency(let currency):
                state.destination = .selectCurrency(.init(selectedCurrency: currency))
                return .none
            case .tapChoosePhoto:
                state.choosePhotoDialog = .init(title: {
                    TextState("写真の選択")
                }, actions: {
                    ButtonState(role: .cancel) {
                      TextState("キャンセル")
                    }
                    ButtonState(action: .fromCamera) {
                      TextState("カメラ")
                    }
                    ButtonState(action: .fromLibrary) {
                      TextState("ライブラリー")
                    }
                }, message: {
                    TextState("选择照片吧")
                })
                return .none
            case .choosePhotoDialog(.presented(.fromCamera)):
                // TODO:
                // present imagepicker
                return .none
            case .choosePhotoDialog(.presented(.fromLibrary)):
                // TODO:
                // present photo picker
                state.showPhotoLib = true
                return .none
            case .input(let value):
                switch value {
                case .equal:
                    return makeCalculate(state: &state, value: value)
                case .delete:
                    if value == .delete,
                       !state.inputValue.isEmpty {
                        state.inputValue.removeLast()
                    }
                    return .none
                case .point:
                    if value == .point,
                       state.inputValue.pointable {
                        state.inputValue += "."
                    }
                    return .none
                case .allClear:
                    if value == .allClear {
                        state.inputValue = ""
                        state.currentOperator = nil
                        state.currentOperand = nil
                    }
                    return .none
                case .plus:
                    return setOperator(state: &state, op: .add)
                default:
                    return setNumber(state: &state, value: value)
                }
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        .ifLet(\.$choosePhotoDialog, action: /Action.choosePhotoDialog)
    }
    
    func setNumber(state: inout State, value: AccountInput) -> Effect<Action> {
        if Operator.allCasesValue.contains(state.inputValue) {
            state.inputValue = ""
        }
        if state.inputValue.count > 8 { return .none }
        state.inputValue += value.text
        return .none
      }

    func setOperator(state: inout State, op: Operator) -> Effect<Action> {
        state.currentOperator = op
        state.currentOperand = state.inputValue
        state.inputValue = op.rawValue
        return .none
    }

    func makeCalculate(state: inout State, value: AccountInput) -> Effect<Action> {
        guard let op = state.currentOperator,
              let operand = Double(state.currentOperand ?? ""),
              let inputValue = Double(state.inputValue) else {
            return .none
        }
        switch op {
        case .add:
            state.inputValue = String(operand + inputValue)
        case .subtract:
            state.inputValue = String(operand - inputValue)
        }
        state.currentOperand = nil
        state.currentOperator = nil
        return .none
    }

    public struct Destination: Reducer {
        public enum State: Equatable {
            case selectCategory(CategoriesStore.State)
            case selectSubCategory(SubCategoriesStore.State)
            case selectCurrency(CurrencyStore.State)
        }

        public enum Action: Equatable {
            case selectCategory(CategoriesStore.Action)
            case selectSubCategory(SubCategoriesStore.Action)
            case selectCurrency(CurrencyStore.Action)
        }

        public var body: some Reducer<State, Action> {
            Scope(state: /State.selectCategory, action: /Action.selectCategory) {
                CategoriesStore()
            }
            Scope(state: /State.selectSubCategory, action: /Action.selectSubCategory) {
                SubCategoriesStore()
            }
            Scope(state: /State.selectCurrency, action: /Action.selectCurrency) {
                CurrencyStore()
            }
        }
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

extension String {
    var pointable: Bool {
        if isEmpty { return false }
        if contains(".") { return false }
        return Double(self) != nil
    }
}
