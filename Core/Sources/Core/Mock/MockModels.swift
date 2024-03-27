//
//  File.swift
//  
//
//  Created by Marcos Meng on 2023/08/31.
//

import Foundation
import Fakery

public let modelFaker = Faker(locale: "ja")
public extension [AccountBook] {
    static func stub() -> [AccountBook] {
        let number = modelFaker.number.randomInt(min: 0, max: 10)
        var result: [AccountBook] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}


extension AccountBook {
    static func stub() -> AccountBook {
        return AccountBook(
            owner: .stub(),
            participacer: [
                .stub(),
                .stub()
            ],
            bills: [
                .stub(),
                .stub(),
                .stub()
            ],
            id: modelFaker.number.increasingUniqueId().stringValue,
            name: modelFaker.name.title(),
            createdAt: modelFaker.date.between(.init(timeIntervalSince1970: 1661906440), .init()).systemFormatDate
        )
    }
}

public extension [Participacer] {
    static func stub() -> [Participacer] {
        let number = modelFaker.number.randomInt(min: 0, max: 15)
        var result: [Participacer] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}


public extension Participacer {
    static func stub() -> Participacer {
        .init(
            permission: .init(rawValue: modelFaker.number.randomInt(min: 0, max: 2))!,
            id: modelFaker.number.increasingUniqueId().stringValue,
            name: modelFaker.name.name()
        )
    }
}

extension User {
    static func stub() -> User {
        return User(
            id: modelFaker.number.increasingUniqueId().stringValue,
            name: modelFaker.name.name()
        )
    }
}

public extension Bill {
    static func stub() -> Bill {
        Bill(
            id: modelFaker.number.increasingUniqueId().stringValue,
            value: modelFaker.number.randomDouble(),
            type: .init(rawValue: modelFaker.number.randomInt(min: 0, max: 2))!,
            mainCategory: .stub(),
            subCategory: .stub(),
            createdAt: modelFaker.date.between(.init(timeIntervalSince1970: 1661906440), .init()).systemFormatDate,
            updatedAt: modelFaker.date.between(.init(timeIntervalSince1970: 1661906440), .init()).systemFormatDate,
            createdByUser: .stub(),
            updatedByUser: .stub(),
            description: modelFaker.name.name()
        )
    }
}

extension BillMainCategory {
    static func stub() -> BillMainCategory {
        .init(
            id: modelFaker.number.increasingUniqueId().stringValue,
            name: modelFaker.name.title(),
            subCategories: [
                .stub(),
                .stub(),
                .stub()
            ])
    }
}

public extension [BillMainCategory] {
    static func stub() -> [BillMainCategory] {
        let number = modelFaker.number.randomInt(min: 10, max: 15)
        var result: [BillMainCategory] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}

extension BillSubCategory {
    static func stub() -> BillSubCategory {
        .init(id: modelFaker.number.increasingUniqueId().stringValue,
              name: modelFaker.name.title()
        )
    }
}

extension CurrencyModel {
    static func stub() -> CurrencyModel {
        .init(shortName: modelFaker.name.prefix(), fullName: modelFaker.name.firstName(), rate: modelFaker.number.randomCGFloat(min: 0, max: 2))
    }
}

public extension [CurrencyModel] {
    static func stub() -> [CurrencyModel] {
        let number = modelFaker.number.randomInt(min: 10, max: 15)
        var result: [CurrencyModel] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}

public extension [BillSubCategory] {
    static func stub() -> [BillSubCategory] {
        let number = modelFaker.number.randomInt(min: 10, max: 15)
        var result: [BillSubCategory] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}

public extension [Bill] {
    static func stub() -> [Bill] {
        let number = modelFaker.number.randomInt(min: 0, max: 15)
        var result: [Bill] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}

extension BillSectionData {
    static func stub() -> BillSectionData {
        .init(id: modelFaker.number.increasingUniqueId().stringValue,
              header: modelFaker.date.between(.init(timeIntervalSince1970: 1661906440), .init()).systemFormatDate,
              cells: .stub()
        )
    }
}

public extension [BillSectionData] {
    static func stub() -> [BillSectionData] {
        let number = modelFaker.number.randomInt(min: 0, max: 15)
        var result: [BillSectionData] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
}
