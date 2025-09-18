import SwiftUI
import ComposableArchitecture
import Core

public struct CategorySelectionView: View {
    let store: StoreOf<CategorySelectionStore>

    public init(store: StoreOf<CategorySelectionStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                if let message = viewStore.errorMessage {
                    Section {
                        Text(message)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .onTapGesture {
                                viewStore.send(.clearError)
                            }
                    }
                }

                Section(header: Text("新增大分类")) {
                    TextField(
                        "请输入大分类名称",
                        text: viewStore.binding(
                            get: \.newMainCategoryName,
                            send: CategorySelectionStore.Action.setNewMainCategoryName
                        )
                    )
                    .textInputAutocapitalization(.none)

                    Button("创建大分类") {
                        viewStore.send(.createMainCategory)
                    }
                    .disabled(viewStore.newMainCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewStore.isLoading)
                }

                Section(header: Text("新增小分类")) {
                    Picker(
                        "所属大分类",
                        selection: viewStore.binding(
                            get: \.selectedMainCategoryID,
                            send: CategorySelectionStore.Action.selectMainCategory
                        )
                    ) {
                        Text("未选择").tag(nil as String?)
                        ForEach(viewStore.categories, id: \.id) { category in
                            Text(category.name)
                                .tag(category.id as String?)
                        }
                    }

                    TextField(
                        "请输入小分类名称",
                        text: viewStore.binding(
                            get: \.newSubCategoryName,
                            send: CategorySelectionStore.Action.setNewSubCategoryName
                        )
                    )
                    .textInputAutocapitalization(.none)

                    Button("创建小分类") {
                        viewStore.send(.createSubCategory)
                    }
                    .disabled(
                        viewStore.selectedMainCategoryID == nil ||
                        viewStore.newSubCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        viewStore.isLoading
                    )
                }

                ForEach(viewStore.categories, id: \.id) { category in
                    Section(
                        header: HStack {
                            Text(category.name)
                            Spacer()
                            Text(category.scope == .public ? "公共" : "私人")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    ) {
                        if category.subCategories.isEmpty {
                            Text("暂无小分类")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(category.subCategories, id: \.id) { subCategory in
                                HStack {
                                    Text(subCategory.name)
                                    Spacer()
                                    Text(subCategory.scope == .public ? "公共" : "私人")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("账单分类")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewStore.isLoading {
                        ProgressView()
                    } else {
                        Button(action: { viewStore.send(.refresh) }) {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct CategorySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategorySelectionView(
                store: Store(
                    initialState: CategorySelectionStore.State(
                        categories: [
                            BillMainCategoryModel(
                                id: "1",
                                name: "餐饮",
                                subCategories: [
                                    BillSubCategoryModel(id: "1-1", name: "早餐", mainCategoryID: "1", scope: .public),
                                    BillSubCategoryModel(id: "1-2", name: "午餐", mainCategoryID: "1", scope: .public)
                                ],
                                scope: .public
                            ),
                            BillMainCategoryModel(
                                id: "2",
                                name: "自定义",
                                subCategories: [
                                    BillSubCategoryModel(id: "2-1", name: "兴趣", mainCategoryID: "2", scope: .private)
                                ],
                                scope: .private
                            )
                        ]
                    ),
                    reducer: {
                        CategorySelectionStore()
                    }
                )
            )
        }
    }
}
