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
        var lastInput: AccountInput?
        var tapPlus: Bool
        var billsType: [BillType]
        var selectedBillType: BillType
        var showPhotoLib = false
        
        @PresentationState var destination: Destination.State?
        @PresentationState var choosePhotoDialog: ConfirmationDialogState<Action.ChoosePhotoDialog>?

        public init(title: String = "Payment", 
                    inputValue: String = "",
                    inputDate: Date = .now, // TODO: add date to env DI.
                    inputPlaceholder: String = "0.00",
                    lastInput: AccountInput? = nil,
                    tapPlus: Bool = false,
                    billsType: [BillType] = [.income, .payment],
                    selectedBillType: BillType = .payment
        ) {
            self.title = title
            self.inputValue = inputValue
            self.inputDate = inputDate
            self.lastInput = lastInput
            self.tapPlus = tapPlus
            self.billsType = billsType
            self.inputPlaceholder = inputPlaceholder
            self.selectedBillType = selectedBillType
        }
    }

    public enum Action: Equatable {
        case onAppear
        case tapClose
        case textChanged(String)
        case dateChanged(Date)
        case billsType(BillType)
        case setInputValue(String)
        case tapBigCategory(BillMainCategoryModel?)
        case tapSubCategory(BillSubCategoryModel?)
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
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        .ifLet(\.$choosePhotoDialog, action: /Action.choosePhotoDialog)
    }

    func setLastInput(state: inout State, value: AccountInput?) -> Effect<Action> {
        state.lastInput = value
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
