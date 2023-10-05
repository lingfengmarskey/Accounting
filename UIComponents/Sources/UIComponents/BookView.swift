//
//  BookView.swift
//  
//
//  Created by Marcos Meng on 2023/08/31.
//
import SwiftUI

public struct BookView: View {
    var title: String
    var owner: String
    var id: String

    @Binding var selectedId: String?

    @Environment(\.editMode) private var editMode

    public init(
        title: String,
        owner: String,
        id: String,
        selectedId: Binding<String?>)
    {
        self.title = title
        self.owner = owner
        self.id = id
        _selectedId = selectedId
    }

    public var body: some View {
        HStack {
            if editMode?.wrappedValue == .inactive {
                if  let selectedId = selectedId,
                   selectedId == id {
                    Image(systemName: "checkmark.circle.fill")
                } else {
                    Image(systemName: "checkmark.circle")
                }
            }
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
        .onTapGesture {
            if editMode?.wrappedValue == .inactive {
                selectedId = id
            }
        }
    }
}



struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(
            title: "FamilyFamily",
            owner: "Lee",
            id: "123",
            selectedId: .constant("123"))
            .previewLayout(.sizeThatFits)
    }
}
