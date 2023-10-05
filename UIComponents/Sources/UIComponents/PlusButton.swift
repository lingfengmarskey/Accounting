//
//  PlusButton.swift
//  
//
//  Created by Marcos Meng on 2023/10/05.
//

import Foundation
import SwiftUI

public struct PlusButton: View {
    
    var onTap: (() -> Void)
    
    var disable: Bool

    @Environment(\.editMode) private var editMode

    private var isEditing: Bool {
        editMode?.wrappedValue == .active
    }

    private var isBackgroundDisable: Bool {
        if !isEditing { return disable }
        return false
    }
    
    public init(disable: Bool, onTap: @escaping () -> Void) {
        self.onTap = onTap
        self.disable = disable
    }
    
    public var body: some View {
        Button {
            onTap()
        } label: {
            if isEditing {
                Image(systemName: "plus")
                    .renderingMode(.some(.template))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .padding(8)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.white, lineWidth: 2)
                    )
            } else {
                Text("OK")
                    .foregroundColor(.white)
                    .fontWeight(.heavy)
                    .padding(.leading)
                    .padding(.trailing)
            }
        }
        .padding(10)
        .background(isBackgroundDisable ? Color.gray : Color.black)
        .cornerRadius(25)
        .disabled(disable)
    }
}

struct PlusButton_Previews: PreviewProvider {
    static var previews: some View {
        PlusButton(disable: false) {
            
        }
    }
}
