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

@Reducer
public struct InputAccountsStore {
    @ObservableState
    public struct State {
        // payment or income or others in the futrue.
        var title: String
        var inputValue: String
        var inputDate: Date
        var inputPlaceholder: String
        var tapPlus: Bool
        var billsType: [BillType]
        var selectedBillType: BillType
        var selectedImageData: Data?
        var isCameraPickerPresented = false
        var isPhotoLibraryPresented = false
        var ledger: AccountBook
        var selectedCurrency: CurrencyModel
        var selectedMainCategory: BillMainCategory?
        var selectedSubCategory: BillSubCategory?
        var memo: String
        var isSaving: Bool
        var currentOperator: Operator?
        var currentOperand: String?

        var isFormValid: Bool {
            guard Double(inputValue) != nil else { return false }
            guard let mainCategory = selectedMainCategory else { return false }
            return !mainCategory.id.isEmpty
        }

        @Presents var destination: Destination.State?
        @Presents var choosePhotoDialog: ConfirmationDialogState<Action.ChoosePhotoDialog>?
        @Presents var alert: AlertState<Action.Alert>?

        public init(title: String = "Payment",
                    inputValue: String = "",
                    inputDate: Date = .now, // TODO: add date to env DI.
                    inputPlaceholder: String = "0.00",
                    tapPlus: Bool = false,
                    billsType: [BillType] = [.income, .payment],
                    selectedBillType: BillType = .payment,
                    ledger: AccountBook,
                    selectedCurrency: CurrencyModel = .usd,
                    selectedMainCategory: BillMainCategory? = nil,
                    selectedSubCategory: BillSubCategory? = nil,
                    memo: String = "",
                    isSaving: Bool = false,
                    selectedImageData: Data? = nil,
                    isCameraPickerPresented: Bool = false,
                    isPhotoLibraryPresented: Bool = false
        ) {
            if title.isEmpty {
                self.title = selectedBillType == .income ? "Income" : "Payment"
            } else {
                self.title = title
            }
            self.inputValue = inputValue
            self.inputDate = inputDate
            self.tapPlus = tapPlus
            self.billsType = billsType
            self.inputPlaceholder = inputPlaceholder
            self.selectedBillType = selectedBillType
            self.ledger = ledger
            self.selectedCurrency = selectedCurrency
            self.selectedMainCategory = selectedMainCategory
            self.selectedSubCategory = selectedSubCategory
            self.memo = memo
            self.isSaving = isSaving
            self.selectedImageData = selectedImageData
            self.isCameraPickerPresented = isCameraPickerPresented
            self.isPhotoLibraryPresented = isPhotoLibraryPresented
        }
    }

    public enum Operator: String, Equatable, CaseIterable {
        case add = "+"
        case subtract = "-"
        
        static var allCasesValue: Set<String> {
            ["+", "-"]
        }
    }

    public enum Action {
        case onAppear
        case tapClose
        case textChanged(String)
        case dateChanged(Date)
        case billsType(BillType)
        case setInputValue(String)
        case setMemo(String)
        case tapBigCategory(BillMainCategory?)
        case tapSubCategory(BillSubCategory?)
        case tapCurrency
        case input(AccountInput)
//        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case tapChoosePhoto
        case choosePhotoDialog(PresentationAction<ChoosePhotoDialog>)
        case presentImagePicker(ImageSource)
        case imagePicked(Data)
        case removeImage
        case tapRecord
        case saveResponse(Result<Bill, Error>)
        case alert(PresentationAction<Alert>)
        @CasePathable
        public enum ChoosePhotoDialog: Equatable {
            case fromCamera
            case fromLibrary
        }
        public enum ImageSource: Equatable {
            case camera
            case photoLibrary
        }
        public enum Alert: Equatable {
            case acknowledge
        }
    }


    @Dependency(\.dismiss) var dismiss
    @Dependency(\.transactionClient) var transactionClient

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
                state.title = value == .income ? "Income" : "Payment"
                return .none
            case .setInputValue(let value):
                state.inputValue = value
                return .none
            case .setMemo(let value):
                state.memo = value
                return .none
            case .tapBigCategory(let category):
                state.destination = .selectCategory(
                    .init(
                        selectedCategory: category ?? state.selectedMainCategory
                    )
                )
                return .none
            case .tapSubCategory(let category):
                guard state.selectedMainCategory != nil else { return .none }
                let selected = category ?? state.selectedSubCategory
                let subCategories = state.selectedMainCategory?.subCategories ?? []
                state.destination = .selectSubCategory(
                    .init(
                        subCategories: subCategories,
                        selectedSubCategory: selected
                    )
                )
                return .none
            case .tapCurrency:
                state.destination = .selectCurrency(
                    .init(
                        selectedCurrency: state.selectedCurrency
                    )
                )
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
                return .send(.presentImagePicker(.camera))
            case .choosePhotoDialog(.presented(.fromLibrary)):
                return .send(.presentImagePicker(.photoLibrary))
            case .presentImagePicker(.camera):
                state.isCameraPickerPresented = true
                state.destination = .fromCamera(
                    .init(source: .camera)
                )
                return .none
            case .presentImagePicker(.photoLibrary):
                state.isPhotoLibraryPresented = true
                state.destination = .fromLibrary(
                    .init(source: .photoLibrary)
                )
                return .none
            case let .destination(.presented(.fromCamera(.didFinishPicking(data)))):
                return .send(.imagePicked(data))
            case .destination(.presented(.fromCamera(.didCancel))):
                state.isCameraPickerPresented = false
                state.destination = nil
                return .none
            case let .destination(.presented(.fromLibrary(.didFinishPicking(data)))):
                return .send(.imagePicked(data))
            case .destination(.presented(.fromLibrary(.didCancel))):
                state.isPhotoLibraryPresented = false
                state.destination = nil
                return .none
            case .destination(.dismiss):
                state.isCameraPickerPresented = false
                state.isPhotoLibraryPresented = false
                return .none
            case let .imagePicked(data):
                state.selectedImageData = data
                state.isCameraPickerPresented = false
                state.isPhotoLibraryPresented = false
                state.destination = nil
                return .none
            case .removeImage:
                state.selectedImageData = nil
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
            case .destination(.presented(.selectCategory(.onTap(let category)))):
                state.selectedMainCategory = category
                state.selectedSubCategory = nil
                state.destination = nil
                return .none
            case .destination(.presented(.selectSubCategory(.onTap(let category)))):
                state.selectedSubCategory = category
                state.destination = nil
                return .none
            case .destination(.presented(.selectCurrency(.onTap(let currency)))):
                state.selectedCurrency = currency
                state.destination = nil
                return .none
            case .tapRecord:
                guard !state.isSaving else { return .none }
                guard let value = Double(state.inputValue) else {
                    state.alert = Self.makeAlert(message: "金額を入力してください。")
                    return .none
                }
                guard let mainCategory = state.selectedMainCategory else {
                    state.alert = Self.makeAlert(message: "カテゴリを選択してください。")
                    return .none
                }
                guard let subCategory = state.selectedSubCategory else {
                    state.alert = Self.makeAlert(message: "サブカテゴリを選択してください。")
                    return .none
                }
                var descriptionText = state.memo
                let currency = state.selectedCurrency.shortName
                if !currency.isEmpty {
                    if descriptionText.isEmpty {
                        descriptionText = "Currency: \(currency)"
                    } else {
                        descriptionText += " | Currency: \(currency)"
                    }
                }
                state.isSaving = true
                let billType = state.selectedBillType
                let date = state.inputDate
                let ledger = state.ledger
                return .run { send in
                    let result = await Result {
                        try await transactionClient.addBill(
                            ledger,
                            value,
                            billType,
                            mainCategory,
                            subCategory,
                            date,
                            descriptionText.isEmpty ? nil : descriptionText
                        )
                    }
                    await send(.saveResponse(result))
                }
            case .saveResponse(.success):
                state.isSaving = false
                return .run { _ in
                    await self.dismiss()
                }
            case .saveResponse(.failure):
                state.isSaving = false
                state.alert = Self.makeAlert(message: "保存に失敗しました。再試行してください。")
                return .none
            case .alert(.presented(.acknowledge)):
                state.alert = nil
                return .none
            case .alert:
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .ifLet(\.$choosePhotoDialog, action: \.choosePhotoDialog)
        .ifLet(\.$alert, action: \.alert)
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

    @Reducer
    public enum Destination {
        case selectCategory(CategoriesStore)
        case selectSubCategory(SubCategoriesStore)
        case selectCurrency(CurrencyStore)
        case fromCamera(ImagePicker)
        case fromLibrary(ImagePicker)
    }
}

extension InputAccountsStore.Destination {
    @Reducer
    public struct ImagePicker {
        @ObservableState
        public struct State: Equatable, Identifiable {
            public let id: UUID
            public let source: Source

            public init(id: UUID = UUID(), source: Source) {
                self.id = id
                self.source = source
            }
        }

        public enum Source: Equatable {
            case camera
            case photoLibrary
        }

        public enum Action: Equatable {
            case didFinishPicking(Data)
            case didCancel
        }

        public var body: some ReducerOf<Self> {
            Reduce { _, _ in
                .none
            }
        }
    }
}
 
extension InputAccountsStore {
    struct Constants {
        static let usdCurrency = CurrencyModel.usd
        static let placeholderLedger = AccountBook(
            owner: .init(id: "", name: ""),
            participacer: [],
            bills: [],
            id: "",
            name: "",
            createdAt: ""
        )
    }

    static func makeAlert(message: String) -> AlertState<Action.Alert> {
        AlertState(
            title: { TextState("エラー") },
            actions: {
                ButtonState(action: .acknowledge) {
                    TextState("OK")
                }
            },
            message: { TextState(message) }
        )
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

