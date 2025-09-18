import SwiftUI
import ComposableArchitecture
import Core

public struct CategorySelectionView: View {
    @Perception.Bindable var store: StoreOf<CategorySelectionStore>

    public init(store: StoreOf<CategorySelectionStore>) {
        self.store = store
    }

    public var body: some View {
        List {
            if let message = store.state.errorMessage {
                Section {
                    Text(message)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .onTapGesture {
                            store.send(.clearError)
                        }
                }
            }
            Section(header: Text("新增大分类")) {
                TextField("请输入大分类名称",
                          text: $store.newMainCategoryName)
                .textInputAutocapitalization(.none)
                Button("创建大分类") {
                    store.send(.createMainCategory)
                }
                .disabled(
                    store.newMainCategoryName
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                    || store.isLoading
                )
            }
            
            Section(header: Text("新增小分类")) {
                Picker(
                    "所属大分类",
                    selection: $store.selectedMainCategoryID
                ) {
                    Text("未选择").tag(nil as String?)
                    ForEach(store.categories, id: \.id) { category in
                        Text(category.name)
                            .tag(category.id as String?)
                    }
                }
                
                TextField(
                    "请输入小分类名称",
                    text: $store.newSubCategoryName
                )
                .textInputAutocapitalization(.none)
                
                Button("创建小分类") {
                    store.send(.createSubCategory)
                }
                .disabled(
                    store.selectedMainCategoryID == nil ||
                    store.newSubCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    store.isLoading
                )
            }
            
            ForEach(store.categories, id: \.id) { category in
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
                if store.state.isLoading {
                    ProgressView()
                } else {
                    Button(action: { store.send(.refresh) }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
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
                            BillMainCategory(
                                id: "1",
                                name: "餐饮",
                                subCategories: [
                                    BillSubCategory(id: "1-1", name: "早餐", mainCategoryID: "1", scope: .public),
                                    BillSubCategory(id: "1-2", name: "午餐", mainCategoryID: "1", scope: .public)
                                ],
                                scope: .public
                            ),
                            BillMainCategory(
                                id: "2",
                                name: "自定义",
                                subCategories: [
                                    BillSubCategory(id: "2-1", name: "兴趣", mainCategoryID: "2", scope: .private)
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
