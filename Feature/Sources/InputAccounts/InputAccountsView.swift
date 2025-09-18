//
//  InputAccountsView.swift
//
//
//  Created by Marcos Meng on 2023/10/21.
//

import ComposableArchitecture
import Foundation
import SwiftUI
import UIKit
import UIComponents
import Categories
import SubCategories
import Currency

public struct InputAccountsView: View {
    @Perception.Bindable var store: StoreOf<InputAccountsStore>

    public init(_ store: StoreOf<InputAccountsStore>) {
        self.store = store
    }

    public var body: some View {
        NavigationStack {
            scrollView
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .navigationTitle(store.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            store.send(.tapClose)
                        }, label: {
                            Image(systemName: "xmark")
                        })
                    }
                })
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
        .onAppear(perform: {
            store.send(.onAppear)
        })
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

    private var isSubCategoryDisabled: Bool {
        store.selectedMainCategory == nil
    }

    private var isRecordDisabled: Bool {
        !store.isFormValid || store.isSaving
    }

    var scrollView: some View {
        ScrollView {
            VStack(spacing: 15) {
                
                // display
                Group {
                    HStack {
                        BoldTextField(
                            textValue: $store.inputValue.sending(\.textChanged),
                            placeholderText: store.state.inputPlaceholder,
                            fontSize: 48
                        ) { item in
                            store.send(.input(item))
                        }
                        .font(.system(size: 48, weight: .bold))
                        Spacer()
                    }
                }
                // currency
                Group {
                    HStack {
                        Button(action: {
                            store.send(.tapCurrency)
                        }, label: {
                            HStack {
                                Text(store.selectedCurrency.shortName)
                                    .font(.system(size: 20, weight: .bold))
                                Image(systemName: "chevron.down")
                            }
                            .foregroundStyle(Color.black)
                        })
                        Spacer()
                    }
                }
                // type
                ScrollView(
                    .horizontal,
                    showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(store.billsType, id: \.self) { value in
                                
                                Button {
                                    store.send(.billsType(value))
                                } label: {
                                    HStack {
                                        value.icon
                                            .renderingMode(.template)
                                        Text(value.title)
                                            .font(.system(size: 20, weight: .bold))
                                    }
                                    .padding()
                                }
                                .foregroundStyle(store.selectedBillType == value ? Color.white : Color.black)
                                .background(store.selectedBillType == value ? Color.flatGreen : Color.lightGray)
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                
                // big category
                Group {
                    HStack {
                        Button {
                            store.send(.tapBigCategory(store.selectedMainCategory))
                        } label: {
                            HStack {
                                VStack {
                                    Text(store.selectedMainCategory?.name ?? "大分類")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
                                .padding(.top, 15)
                                .padding(.leading, 15)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .frame(width: 28)
                            }
                        }
                        .frame(width: 150, height: 90)
                        .background(Color.lightGray)
                        .foregroundStyle(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        Spacer()
                    }
                }
                // sub category
                Group {
                    HStack {
                        Button {
                            store.send(.tapSubCategory(store.selectedSubCategory))
                        } label: {
                            HStack {
                                VStack {
                                    Text(store.selectedSubCategory?.name ?? "小分類")
                                        .font(.system(size: 20))
                                    Spacer()
                                }
                                .padding(.top, 15)
                                .padding(.leading, 15)
                                Spacer()
                                Image(systemName: "chevron.forward")
                                    .frame(width: 28)
                            }
                        }
                        .frame(width: 200, height: 65)
                        .background(Color.lightGray.opacity(isSubCategoryDisabled ? 0.6 : 1))
                        .foregroundStyle(isSubCategoryDisabled ? Color.gray : Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSubCategoryDisabled ? Color.gray.opacity(0.5) : Color.clear, lineWidth: 1)
                        )
                        .opacity(isSubCategoryDisabled ? 0.6 : 1)
                        .disabled(isSubCategoryDisabled)
                        Spacer()
                    }
                }
                // Date
                Group {
                    HStack {
                        DatePicker("", selection: $store.inputDate.sending(\.dateChanged), displayedComponents: [.date, .hourAndMinute])
//                            .labelsHidden()
                        Spacer()
                    }
                }
                // photoes
                Group {
                    photoSection
                }
                
                // submit buttons
                Spacer()
                Group {
                    Button {
                        store.send(.tapRecord)
                    } label: {
                        HStack {
                            Spacer()
                            if store.isSaving {
                                ProgressView()
                            } else {
                                Text("Record")
                                    .font(.system(size: 24, weight: .bold))
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 68)
                    .background(isRecordDisabled ? Color.gray.opacity(0.3) : Color.black)
                    .foregroundStyle(isRecordDisabled ? Color.white.opacity(0.7) : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(isRecordDisabled)

                }
            }
        }
    }
    
}

private extension InputAccountsView {
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
                        VStack {
                            HStack(alignment: .center) {
                                Text("写真")
                                    .font(.system(size: 20))
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(.leading, 15)
                        .padding(.top, 15)
                    }
                }
            }
            .frame(height: 150)
            .background(Color.lightGray)
            .foregroundStyle(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 8))

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


struct AsistButton: View {
    let title: String
    let onTap: () -> ()
    
    var body: some View {
        Button {
            onTap()
        } label: {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background {
                    Color.green
                }
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}


#Preview {
    InputAccountsView(
        Store(initialState: InputAccountsStore.State(ledger: .none), reducer: {
            InputAccountsStore()
        })
    )
}
