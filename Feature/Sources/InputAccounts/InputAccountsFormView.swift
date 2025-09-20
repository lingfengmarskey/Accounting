//
//  InputAccountsFormView.swift
//
//

import ComposableArchitecture
import SwiftUI
import UIKit
import UIComponents
import Categories
import SubCategories
import Currency
import Core

public struct InputAccountsFormView: View {
    @Perception.Bindable var store: StoreOf<InputAccountsStore>

    public init(_ store: StoreOf<InputAccountsStore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    amountSection
                    typePicker
                    categorySection
                    dateSection
                    memoSection
                    photoPickerSection
                    saveButton
                }
                .padding(.vertical, 24)
            }
            .padding(.horizontal, 20)
            .navigationTitle(store.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { store.send(.tapClose) }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.selectCategory, action: \.destination.selectCategory)
            ) { store in
                CategoriesView(store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.selectSubCategory, action: \.destination.selectSubCategory)
            ) { store in
                SubCategoriesView(store)
            }
            .navigationDestination(
                item: $store.scope(state: \.destination?.selectCurrency, action: \.destination.selectCurrency)
            ) { store in
                CurrencyView(store)
            }
        }
        .onAppear { store.send(.onAppear) }
        .confirmationDialog($store.scope(state: \.choosePhotoDialog, action: \.choosePhotoDialog))
        .alert($store.scope(state: \.alert, action: \.alert))
        .sheet(
            item: $store.scope(state: \.destination?.fromCamera, action: \.destination.fromCamera)
        ) { store in
            ImagePickerContainer(
                source: .camera,
                onImagePicked: { data in
                    store.send(.didFinishPicking(data))
                },
                onCancel: {
                    store.send(.didCancel)
                }
            )
        }
        .sheet(
            item: $store.scope(state: \.destination?.fromLibrary, action: \.destination.fromLibrary)
        ) { store in
            ImagePickerContainer(
                source: .photoLibrary,
                onImagePicked: { data in
                    store.send(.didFinishPicking(data))
                },
                onCancel: {
                    store.send(.didCancel)
                }
            )
        }
    }
}

private extension InputAccountsFormView {
    var amountSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Amount")
                .font(.headline)
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                TextField(
                    store.inputPlaceholder,
                    text: Binding(
                        get: { store.inputValue },
                        set: { store.send(.setInputValue(sanitizeAmountInput($0))) }
                    )
                )
                .font(.system(size: 48, weight: .bold))
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.primary)

                Spacer(minLength: 12)

                Button(action: { store.send(.tapCurrency) }) {
                    HStack(spacing: 6) {
                        Text(store.selectedCurrency.shortName)
                            .font(.system(size: 20, weight: .bold))
                        Image(systemName: "chevron.down")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.lightGray)
                    )
                    .foregroundStyle(Color.black)
                }
            }
        }
    }

    var typePicker: some View {
        Picker(
            "Bill Type",
            selection: Binding(
                get: { store.selectedBillType },
                set: { store.send(.billsType($0)) }
            )
        ) {
            ForEach(store.billsType, id: \.self) { value in
                Text(value.title).tag(value)
            }
        }
        .pickerStyle(.segmented)
    }

    var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category")
                .font(.headline)
            if !availableMainCategories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableMainCategories, id: \.id) { category in
                            mainCategoryChip(category)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            selectionButton(
                title: "Main Category",
                value: store.selectedMainCategory?.name ?? "大分類",
                action: { store.send(.tapBigCategory(store.selectedMainCategory)) }
            )
            if let mainCategory = store.selectedMainCategory {
                subCategoryChips(mainCategory)
            }
            selectionButton(
                title: "Sub Category",
                value: store.selectedSubCategory?.name ?? "小分類",
                action: { store.send(.tapSubCategory(store.selectedSubCategory)) }
            )
            .disabled(isSubCategoryDisabled)
            .opacity(isSubCategoryDisabled ? 0.6 : 1)
        }
    }

    func subCategoryChips(_ mainCategory: BillMainCategory) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 10)], spacing: 10) {
            ForEach(mainCategory.subCategories, id: \.id) { subCategory in
                Button {
                    store.send(
                        .destination(
                            .presented(
                                .selectSubCategory(.onTap(subCategory))
                            )
                        )
                    )
                } label: {
                    Text(subCategory.name)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .foregroundStyle(
                            store.selectedSubCategory == subCategory ? Color.white : Color.black
                        )
                        .background(
                            Capsule()
                                .fill(
                                    store.selectedSubCategory == subCategory ? Color.flatGreen : Color.lightGray
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    func mainCategoryChip(_ category: BillMainCategory) -> some View {
        Button {
            store.send(
                .destination(
                    .presented(
                        .selectCategory(.onTap(category))
                    )
                )
            )
        } label: {
            Text(category.name)
                .font(.system(size: 16, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .foregroundStyle(
                    store.selectedMainCategory == category ? Color.white : Color.black
                )
                .background(
                    Capsule()
                        .fill(
                            store.selectedMainCategory == category ? Color.flatGreen : Color.lightGray
                        )
                )
        }
        .buttonStyle(.plain)
    }

    var dateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Date")
                .font(.headline)
            DatePicker(
                "",
                selection: Binding(
                    get: { store.inputDate },
                    set: { store.send(.dateChanged($0)) }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
        }
    }

    var memoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memo")
                .font(.headline)
            TextField(
                "メモを追加",
                text: Binding(
                    get: { store.memo },
                    set: { store.send(.setMemo($0)) }
                )
            )
            .textFieldStyle(.roundedBorder)
        }
    }

    var photoPickerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Photo")
                .font(.headline)
            photoSection
        }
    }

    var saveButton: some View {
        Button(action: { store.send(.tapRecord) }) {
            HStack {
                Spacer()
                if store.isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text("Record")
                        .font(.system(size: 24, weight: .bold))
                }
                Spacer()
            }
            .padding(.vertical, 16)
        }
        .background(isRecordDisabled ? Color.gray.opacity(0.3) : Color.black)
        .foregroundStyle(isRecordDisabled ? Color.white.opacity(0.7) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .disabled(isRecordDisabled)
    }

    var isSubCategoryDisabled: Bool {
        store.selectedMainCategory == nil
    }

    var isRecordDisabled: Bool {
        !store.isFormValid || store.isSaving
    }

    func selectionButton(title: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.body)
                Spacer()
                Text(value)
                    .font(.body)
                    .foregroundStyle(Color.secondary)
                Image(systemName: "chevron.forward")
                    .foregroundStyle(Color.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.lightGray.opacity(0.6))
            )
            .foregroundStyle(Color.black)
        }
    }

    var availableMainCategories: [BillMainCategory] {
        var result: [BillMainCategory] = []
        var seen: Set<String> = []

        for bill in store.ledger.bills {
            let category = bill.mainCategory
            if seen.insert(category.id).inserted {
                result.append(category)
            }
        }

        if let selected = store.selectedMainCategory, seen.insert(selected.id).inserted {
            result.append(selected)
        }

        return result
    }

    func sanitizeAmountInput(_ value: String) -> String {
        var result = ""
        var hasDecimal = false

        for character in value {
            if character.isNumber {
                result.append(character)
            } else if character == "." {
                if hasDecimal { continue }
                hasDecimal = true
                result.append(character)
            }
        }

        return result
    }

    var photoSection: some View {
        ZStack(alignment: .topTrailing) {
            Button {
                store.send(.tapChoosePhoto)
            } label: {
                ZStack {
                    if let image = imageFromData(store.selectedImageData) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .clipped()
                    } else {
                        VStack(alignment: .leading) {
                            Text("写真")
                                .font(.system(size: 20))
                            Spacer()
                        }
                        .padding(.leading, 15)
                        .padding(.top, 15)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(height: 150)
            .background(Color.lightGray)
            .foregroundStyle(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if store.selectedImageData != nil {
                Button {
                    store.send(.removeImage)
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(8)
                .buttonStyle(.plain)
            }
        }
    }

    func imageFromData(_ data: Data?) -> Image? {
        guard
            let data,
            let uiImage = UIImage(data: data)
        else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}

private struct ImagePickerContainer: UIViewControllerRepresentable {
    let source: UIImagePickerController.SourceType
    let onImagePicked: (Data) -> Void
    let onCancel: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onImagePicked: onImagePicked, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = source
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImagePicked: (Data) -> Void
        let onCancel: () -> Void

        init(onImagePicked: @escaping (Data) -> Void, onCancel: @escaping () -> Void) {
            self.onImagePicked = onImagePicked
            self.onCancel = onCancel
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8)
            {
                onImagePicked(data)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onCancel()
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    InputAccountsFormView(
        Store(initialState: InputAccountsStore.State(ledger: .none), reducer: {
            InputAccountsStore()
        })
    )
}
