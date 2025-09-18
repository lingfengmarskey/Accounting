import AccountBookConfig
import Billslist
import ComposableArchitecture
import SwiftUI

public struct RootView: View {
    
    @Perception.Bindable var store: StoreOf<RootStore>

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
        .fullScreenCover(item: $store.scope(state:\.destination?.addBook, action: \.destination.addBook), content: { store in
            AccountBookConfigView(store)
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
