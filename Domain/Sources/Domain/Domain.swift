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
