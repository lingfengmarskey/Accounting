//
//  PlusButton.swift
//  
//
//  Created by Marcos Meng on 2023/10/05.
//

import Foundation
import SwiftUI

public struct FooterButton: View {

    @Environment(\.editMode) private var editMode
    @Environment(\.isEnabled) private var isEnabled
    
    var onOK: (() -> Void)
    var onAdd: (() -> Void)

    private var backgroundColor: Color {
        if isEditing {
            return .black
        }
        return isEnabled ? Color.black : .gray
    }
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    public init(onOK: @escaping () -> Void,
                onAdd: @escaping () -> Void) {
        self.onOK = onOK
        self.onAdd = onAdd
    }

    public var body: some View {
        Button(action: {
            if isEditing {
                onAdd()
            } else {
                onOK()
            }
        }, label: {
            Text(isEditing ? "Add" : "OK")
                .fontWeight(.heavy)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .foregroundColor(.white)
                .background(backgroundColor)
                .cornerRadius(25)
                .animation(.easeInOut, value: editMode?.wrappedValue)
        })
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        FooterButton {
            
        } onAdd: {
            
        }
    }
}
