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

    var onTapDetail: ((String) -> Void)
    
    @Binding var selectedId: String?

    @Environment(\.editMode) private var editMode
    
    public init(
        title: String,
        owner: String,
        id: String,
        selectedId: Binding<String?>,
        onTapDetail: @escaping (String) -> Void
    ) {
        self.title = title
        self.owner = owner
        self.id = id
        self.onTapDetail = onTapDetail
        _selectedId = selectedId
    }

    public var body: some View {
        HStack(alignment: .center) {
            Group {
                if editMode?.wrappedValue.isEditing == false {
                    if  let selectedId = selectedId,
                        selectedId == id {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Image(systemName: "checkmark.circle")
                    }
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text(title)
                            .font(.system(size: 20, weight: .regular, design: .serif))
                            .lineLimit(1)
                        Spacer()
                    }

                    Text(owner)
                        .font(.system(size: 14, weight: .ultraLight, design: .serif))
                        .foregroundColor(.black)
                }
            }
            .onTapGesture {
                if editMode?.wrappedValue.isEditing == false {
                    selectedId = id
                }
            }
            Button(action: { onTapDetail(id) }, label: {
                Image(systemName: "info.circle")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.black)
            })
            .padding(.leading, 5)
        }
        
    }
}



struct BookView_Previews: PreviewProvider {
    static var previews: some View {
        BookView(
            title: "FamilyFamily",
            owner: "Lee",
            id: "123",
            selectedId: .constant("123"),
            onTapDetail: { _ in }
        )
            .previewLayout(.sizeThatFits)
    }
}
