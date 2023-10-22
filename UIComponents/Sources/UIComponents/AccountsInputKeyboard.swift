//
//  AccountsInputKeyboard.swift
//
//
//  Created by Marcos Meng on 2023/10/21.
//

import Foundation
import SwiftUI

public struct AccountsInputKeyboard: View {
    let items = [
        "1",
        "2",
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "0",
        ".",
        "+",
    ]
    let gridItems:[GridItem] = [
        GridItem(.flexible(minimum: 50, maximum: .infinity), spacing: 5),
        GridItem(.flexible(minimum: 50, maximum: .infinity), spacing: 5),
        GridItem(.flexible(minimum: 50, maximum: .infinity), spacing: 5),
//        GridItem(.fixed(60), spacing: 5),
//        GridItem(.fixed(60), spacing: 5),
    ]
    
    public init() {
        
    }
    
    public var body: some View {
        Grid {
            GridRow(alignment: .bottom) {
                Text("Row 1")
                ForEach(0..<2) { _ in Color.red }
            }
            GridRow {
                Text("Row 2")
                ForEach(0..<5) { _ in Color.green }
            }
            GridRow {
                Text("Row 3")
                ForEach(0..<4) { _ in Color.blue }
            }
        }
//        HStack(spacing: 5) {
//            LazyVGrid(columns: gridItems, spacing: 5,  content: {
//                ForEach(items, id: \.self) { value in
//                    Text(value)
//                        .frame(maxWidth:.infinity, maxHeight: .infinity)
//                        .padding()
//                        .background(Color.random)
//                }
//            })
//            Spacer()
//            Text("helo")
//            VStack(alignment: .trailing, spacing: 5) {
//                Text("<=")
//                    .frame(width: 55, height: 50)
//                    .background(Color.random)
//                Text("OK")
//                    .frame(width: 55, height: 170)
//                    .background(Color.random)
//            }
//        }
    }
}

#Preview {
    AccountsInputKeyboard()
}

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
