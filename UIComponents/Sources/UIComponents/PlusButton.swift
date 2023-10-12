//
//  PlusButton.swift
//  
//
//  Created by Marcos Meng on 2023/10/05.
//

import Foundation
import SwiftUI

public struct PlusButton: View {
    
    var onSave: (() -> Void)
    var onAdd: (() -> Void)

    @Binding var saveDisable: Bool

    @Environment(\.editMode) private var editMode

    var backgroundColor: Color {
        if isEditing {
            return .black
        }
        return saveDisable ? Color.gray : Color.black
    }
    
    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing == true
    }

    public init(disable: Binding<Bool>, 
                onTap: @escaping () -> Void,
                onAdd: @escaping () -> Void) {
        self.onSave = onTap
        self.onAdd = onAdd
        _saveDisable = disable
    }
    
    public var body: some View {
        Button {
            if isEditing {
               onAdd()
            } else {
                if !saveDisable {
                    onSave()
                }
            }
        } label: {
            Text(isEditing ? "Add" : "OK")
                .fontWeight(.heavy)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .foregroundColor(.white)
                .background(backgroundColor)
        }
        .cornerRadius(25)
        .animation(.easeInOut, value: editMode?.wrappedValue)
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton(disable: .constant(true)) {
        
        } onAdd: {
                
        }

    }
}
