//
//  SingleSelectView.swift
//
//
//  Created by Marcos Meng on 2023/10/15.
//

import Foundation
import SwiftUI

public struct SingleSelectView: View {

    @Binding public var isSelected: Bool

    var title: String
    
    var onTap: (() -> Void)

    public init(
        title: String,
        isSelected: Binding<Bool>,
        onTap: @escaping () -> Void
    ) {
        _isSelected = isSelected
        self.onTap = onTap
        self.title = title
    }
    
    public var body: some View {
        Button(action: onTap, label: {
            HStack {
                Text(title)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .foregroundStyle(.black)
        })
    }
}


class MockSingleSelect: ObservableObject {
    @Published var isSelected = false
}

#Preview {
    SingleSelectView(
        title: "Read Only",
        isSelected: .constant(false)
    ) {
        
    }
}
