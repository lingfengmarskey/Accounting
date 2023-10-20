import AccountBookList
import ComposableArchitecture
import SwiftUI
import Billslist

public struct RootView: View {
    @State var present: Bool = false

    let store: StoreOf<RootStore>

    public init(_ store: StoreOf<RootStore>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(store, observe: { $0 }) { _ in
            VStack {
                Text("Root")
                Button {
                    present.toggle()
                } label: {
                    Text("LIST")
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.gray)
                .cornerRadius(12)
            }
            .fullScreenCover(isPresented: $present) {
                BillslistView(
                    self.store.scope(
                        state: \.bills,
                        action: RootStore.Action.bills
                    )
                )
//                AccountBookListView(
//                    self.store.scope(
//                        state: \.accountBooklistState,
//                        action: RootStore.Action.accountBooklistAction
//                    )
//                )
            }
        }
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
