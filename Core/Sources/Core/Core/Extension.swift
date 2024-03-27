//
//  File.swift
//  
//
//  Created by Marcos Meng on 2023/08/31.
//

import Foundation
extension Int {
    var stringValue: String {
        String(self)
    }
}


extension Date {
    var systemFormatDate: String {
        let dateFormatter = DateFormatter()

        // Set Date/Time Style
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        // Set Locale
        dateFormatter.locale = Locale(identifier: "jp")

        // Convert Date to String
        let res = dateFormatter.string(from: self)
        return res
    }
}

public extension String {
    var firstValue: String {
        let value = String(prefix(1))
        return value
    }

    var asUrl: URL? {
        URL(string: self)
    }
}
