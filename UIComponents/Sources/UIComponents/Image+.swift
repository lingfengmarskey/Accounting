//
//  Image.swift
//
//
//  Created by Marcos Meng on 2023/12/31.
//

import Foundation
import SwiftUI
public extension Image {
 
    static var paymentTypeImage: Image {
        Image("payment", bundle: .module)
    }
    
    static var incomeTypeImage: Image {
        Image("income", bundle: .module)
    }
    
}
