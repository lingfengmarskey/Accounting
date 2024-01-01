//
//  File.swift
//  
//
//  Created by Marcos Meng on 2023/12/31.
//

import Foundation
import SwiftUI
import UIKit

public extension Color {
    static var lightGray: Color {
        return Color("lightGray", bundle: .module)
    }
    
    static var submitColor: Color {
        return Color("submitButtonColor", bundle: .module)
    }
    
    static var flatGreen: Color {
        return Color("flatGreen", bundle: .module)
    }
}

public extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
