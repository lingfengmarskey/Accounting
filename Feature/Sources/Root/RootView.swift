import SwiftUI
import AccountBookList

public struct RootView: View {
    @State var present: Bool = false
    
    public init() {}
    
    public var body: some View {
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
        }.fullScreenCover(isPresented: $present) {
            AccountBookListView()
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

