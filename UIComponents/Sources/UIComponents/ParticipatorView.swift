//
//  ParticipatorView.swift
//  
//
//  Created by Marcos Meng on 2023/10/06.
//

import SwiftUI
import Domain

public struct ParticipatorView: View {

    var onTap: ((User?) -> Void)
    
    var user: User?

    public init(user: User? = nil, onTap: @escaping (User?) -> Void) {
        self.onTap = onTap
        self.user = user
    }

    public var body: some View {
        Button {
            onTap(user)
        } label: {
            if let model = user {
                Text(String(model.name.prefix(1)))
                    .bold()
            } else {
                Image(systemName: "plus")
            }
        }
        .frame(width: 50, height: 50)
        .foregroundColor(.white)
        .background(.black)
        .cornerRadius(25)
    }
}

struct ParticipatorView_Previews: PreviewProvider {
    struct MockUser: User {
        var id: String
        
        var name: String
        
        static let one = MockUser(id: "1", name: "Name")
    }
    static var previews: some View {
        VStack {
            ParticipatorView(user: MockUser.one) { _ in
                
            }
            ParticipatorView { _ in 
                
            }
        }
    }
}
