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
