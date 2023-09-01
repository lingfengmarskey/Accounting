//
//  Book.swift
//  
//
//  Created by Marcos Meng on 2023/08/31.
//
import SwiftUI

public struct BookView: View {
    var title: String
    var owner: String

    public init(
        title: String,
        owner: String
    ) {
        self.title = title
        self.owner = String(owner.prefix(1))
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .regular, design: .serif))
                .lineLimit(1)
            Spacer()
            Text(owner)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .padding(8)
                .foregroundColor(.white)
                .background(Color.gray)
                .cornerRadius(5)
        }
        .padding(5)
    }
}

struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(title: "FamilyFamily", owner: "Lee")
            .previewLayout(.sizeThatFits)
    }
}
