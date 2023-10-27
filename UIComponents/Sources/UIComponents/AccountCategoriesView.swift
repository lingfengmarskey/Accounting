//
//  AccountCategoriesView.swift
//
//
//  Created by Marcos Meng on 2023/10/27.
//

import Foundation
import SwiftUI
public struct AccountCategoriesView: View {
    let cates: [String] = [
        "吃",
        "穿",
        "住",
        "行",
        "玩",
        "学",
        "税",
        "儿",
        "礼",
    ]
    let items: [GridItem] = [
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
        GridItem(.flexible(minimum: 50, maximum: .infinity)),
    ]
    
    public var body: some View {
        LazyVGrid(columns: items, content: {
            ForEach(cates, id: \.self) { tup in
                CategoryButton(title: tup)
            }
        })
    }
    
    public init() {}
    
    struct CategoryButton: View {
        let title: String
        
        var body: some View {
            Button(action: {}, label: {
                Text(title)
                    .font(.system(size: 45, weight: .heavy))
                    .foregroundStyle(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
            .background(Color.random)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

#Preview {
    AccountCategoriesView()
}
