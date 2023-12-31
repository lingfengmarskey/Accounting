//
//  File.swift
//  
//
//  Created by Marcos Meng on 2023/08/31.
//

import Foundation
import Fakery

public let modelFaker = Faker(locale: "ja")
public extension [AccountBookModel] {
    static func stub() -> [AccountBookModel] {
        let number = modelFaker.number.randomInt(min: 0, max: 5)
        var result: [AccountBookModel] = []
        for _ in 0...number {
            result.append(.stub())
        }
        return result
    }
    
}


extension AccountBookModel {
    static func stub() -> AccountBookModel {
        return AccountBookModel(
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

extension ParticipacerModel {
    static func stub() -> ParticipacerModel {
        .init(
            permission: .init(rawValue: modelFaker.number.randomInt(min: 0, max: 2))!,
            id: modelFaker.number.increasingUniqueId().stringValue,
            name: modelFaker.name.name()
        )
    }
}

extension UserModel {
    static func stub() -> UserModel {
        return UserModel(
            id: modelFaker.number.increasingUniqueId().stringValue,
            name: modelFaker.name.name()
        )
    }
}

extension BillModel {
    static func stub() -> BillModel {
        BillModel(
            id: modelFaker.number.increasingUniqueId().stringValue,
            value: modelFaker.number.randomDouble(),
            type: .init(rawValue: modelFaker.number.randomInt(min: 0, max: 1))!,
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

extension BillMainCategoryModel {
    static func stub() -> BillMainCategoryModel {
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

extension BillSubCategoryModel {
    static func stub() -> BillSubCategoryModel {
        .init(id: modelFaker.number.increasingUniqueId().stringValue,
              name: modelFaker.name.title()
        )
    }
}
