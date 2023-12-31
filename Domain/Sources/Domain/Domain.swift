//
//  Domain.swift
//
//
//  Created by Marcos Meng on 2023/08/31.
//

import Foundation

//public protocol AccountBook {
//    var id: String { get }
//    var name: String { get }
//    var owner: User { get }
//    var participacer: [Participacer] { get }
//    var bills: [Bill] { set get }
//    var createdAt: String { get }
//}

public protocol User {
    var id: String  { get }
    var name: String { get }
}

//public protocol Participacer: User {
//    var permission: Permission  { get }
//}

public enum Permission: Int {
    case read = 0
    case write
    case create
}

public enum Role: Int {
    case world = 0
    case authenticated
    case creator
}

//public protocol Bill {
//    var id: String { get }
//    var value: Double { get }
//    var type: BillType { get }
//    var mainCategory: BillMainCategory { get }
//    var subCategory: BillSubCategory { get }
//    var createdAt: String { get }
//    var updatedAt: String { get }
//
//    var createdByUser: User { get }
//    var updatedByUser: User { get }
//    var description: String { get }
//}

public enum BillType: Int {
    case payment = 0
    case income
}

public extension BillType {
    var title: String {
        switch self {
        case .payment:
            "支出"
        case .income:
            "収入"
        }
    }
}

//public protocol BillMainCategory {
//    var id: String { get }
//    var name: String { get }
//    var subCategories: [BillSubCategory] { get }
//}

public protocol BillSubCategory {
    var id: String { get }
    var name: String { get }
}


@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public protocol SectionDataProtocol {
    associatedtype CellData: Identifiable
    associatedtype HeaderData
    associatedtype FooterData
    
    var id: String { get }
    var header: HeaderData? { get }
    var footer: FooterData? { get }
    var cells: [CellData] { get }
}

public enum AccountInput: Equatable {
    case one, two, three, four, five, six, seven, eight, nine, zero
    case plus
    case point
    case delete
    case equal

    public enum InputType: Equatable {
        case numbers
        case symbols
    }

    public var type: InputType {
        switch self {
        case .plus, .delete, .equal, .point:
            return .symbols
        default:
            return .numbers
        }
    }

    public var text: String {
        switch self {
        case .one:
            return "1"
        case .two:
            return "2"
        case .three:
            return "3"
        case .four:
            return "4"
        case .five:
            return "5"
        case .six:
            return "6"
        case .seven:
            return "7"
        case .eight:
            return "8"
        case .nine:
            return "9"
        case .zero:
            return "0"
        case .plus:
            return "+"
        case .delete:
            return "〈"
        case .equal:
            return "="
        case .point:
            return "⚫︎"
        }
    }
}
