import AccountBookList
import Billslist
import ComposableArchitecture
import SwiftUI

public struct RootView: View {
//    @State var present: Bool = false

    @ComposableArchitecture.Bindable var store: StoreOf<RootStore>

    public init(_ store: StoreOf<RootStore>) {
        self.store = store
    }

    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image("logo", bundle: .module)
                Spacer()
            }
            Spacer()
        }
        .background(Color.black)
        .onAppear() {
            store.send(.onAppear)
        }
        .fullScreenCover(item: $store.scope(state:\.destination?.booklist, action: \.destination.booklist), content: { store in
            AccountBookListView(store)
        })
        .fullScreenCover(item: $store.scope(state:\.destination?.billslist, action: \.destination.billslist), content: { store in
            BillslistView(store)
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(Store(
            initialState: RootStore.State(),
            reducer: {}
        ))
    }
}
