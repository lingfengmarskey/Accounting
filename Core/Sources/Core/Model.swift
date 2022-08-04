//
//  Model.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//

import Foundation

/// 账本
///
/// Zone:
/// private/share
/// zoneId: account
///
/// Record:
/// private
struct AccountBook: Identifiable {
    let id: String
    let name: String
    let ownerUser: User
    let participators: [User]
    let createdAt: Date
}

/// 账单
///
/// zone:
/// private
/// zoneId:bill
///
/// Record:
/// private
struct AccountRecord: Identifiable {
    let id: String
    let name: String
    let amount: Int
    let createdAt: Date
    let createdByUser: User
    let updatedByUser: User
    let ownerBook: AccountBook
    let description: String
}

/// 用户
///
/// Zone:
/// No save in cloud, managed by the apple
struct User: Identifiable {
    let id: String
    let name: String
    let authType: AuthType
}

/// 账单类型
enum AccoutnRecordType {
    case payment
    case income
}
/// 账单类别
///
/// Zone:
/// Public
/// zoneId:main_category
///
/// Record:
/// public
struct AccountRecordMainCategory: Identifiable {
    let id: String
    let name: String
    let subCategories: [AccountRecordSubCategory]
}

/// 账单子类别
///
/// Zone:
/// public
/// zoneId:sub_category
///
/// Record:
/// public
struct AccountRecordSubCategory: Identifiable {
    let id: String
    let name: String
}

/// 权限类型
///
/// Managed by the apple.
enum AuthType {
    case read
    case writeRead
    case owner
}
