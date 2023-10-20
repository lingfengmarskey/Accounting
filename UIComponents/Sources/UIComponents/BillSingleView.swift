//
//  BillSingleView.swift
//
//
//  Created by Marcos Meng on 2023/10/20.
//

import Foundation
import SwiftUI

public struct BillSingleView: View {

    let isIncome: Bool
    let value: Double
    let updatedAt: String
    let mainCategory: String

    public init(isIncome: Bool, value: Double, updatedAt: String, mainCategory: String) {
        self.isIncome = isIncome
        self.value = value
        self.updatedAt = updatedAt
        self.mainCategory = mainCategory
    }
    
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(isIncome ? "+" : "-")
                    Text(String(format: "%.2f", value))
                    Spacer()
                }
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(isIncome ? Color.green : Color.red)
                Text(updatedAt)
                    .font(.footnote)
                    .fontWeight(.ultraLight)
            }
            Spacer()
            Text(mainCategory)
                .fontWeight(.bold)
                .frame(width: 40, height: 40)
                .background(Color.mint)
                .clipShape(Circle())
        }
    }
}
