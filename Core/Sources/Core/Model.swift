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
    let ownerBookId: String
    let description: String
    let type: AccountRecord
    let mainCategory: AccountRecordMainCategory
    let subCategory: AccountRecordSubCategory
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
    let subCategoriesId: [String]
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


/**
 open class Participant : NSObject, NSSecureCoding, NSCopying {

     
     @NSCopying open var userIdentity: CKUserIdentity { get }

     
     /** The default participant role is @c CKShareParticipantRolePrivateUser. */
     @available(iOS 12.0, *)
     open var role: CKShare.ParticipantRole

     
     /** The default participant type is @c CKShareParticipantTypePrivateUser. */
     @available(iOS, introduced: 10.0, deprecated: 12.0)
     open var type: CKShare.ParticipantType

     
     open var acceptanceStatus: CKShare.ParticipantAcceptanceStatus { get }

     
     /** The default permission for a new participant is @c CKShareParticipantPermissionReadOnly. */
     open var permission: CKShare.ParticipantPermission
 }
 
 @available(iOS 10.0, *)
 public enum ParticipantAcceptanceStatus : Int, @unchecked Sendable {

     
     case unknown = 0

     case pending = 1

     case accepted = 2

     case removed = 3
 }

 
 /** These permissions determine what share participants can do with records inside that share */
 @available(iOS 10.0, *)
 public enum ParticipantPermission : Int, @unchecked Sendable {

     
     case unknown = 0

     case none = 1

     case readOnly = 2

     case readWrite = 3
 }

 
 /** @abstract The participant type determines whether a participant can modify the list of participants on a share.
  *
  *  @discussion
  *  - Owners can add private users
  *  - Private users can access the share
  *  - Public users are "self-added" when the participant accesses the shareURL.  Owners cannot add public users.
  */
 @available(iOS 12.0, *)
 public enum ParticipantRole : Int, @unchecked Sendable {

     
     case unknown = 0

     case owner = 1

     case privateUser = 3

     case publicUser = 4
 }

 
 @available(iOS, introduced: 10.0, deprecated: 12.0, renamed: "CKShareParticipantRole")
 public enum ParticipantType : Int, @unchecked Sendable {

     
     case unknown = 0

     case owner = 1

     case privateUser = 3

     case publicUser = 4
 }
 
 */
