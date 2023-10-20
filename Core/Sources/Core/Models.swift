//
//  Models.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//
import Domain
import Foundation

/// 账本
///
/// Zone:
/// private/share
/// zoneId: account
///
/// Record:
/// private
public struct AccountBookModel: Equatable, Identifiable {
    public var owner: UserModel
    
    public var participacer: [ParticipacerModel]
    
    public var bills: [BillModel]
    
    public var id: String
    public var name: String
    public var createdAt: String
    
    public init(owner: UserModel, participacer: [ParticipacerModel], bills: [BillModel], id: String, name: String, createdAt: String) {
        self.owner = owner
        self.participacer = participacer
        self.bills = bills
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}


public struct UserModel: Equatable, Identifiable {
    public var id: String
    
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct ParticipacerModel: Equatable, Identifiable, User {
    public var permission: Permission
    
    public var id: String
    
    public var name: String
    
    public init(permission: Permission, id: String, name: String) {
        self.permission = permission
        self.id = id
        self.name = name
    }
}


/// 账单
///
/// zone:
/// private
/// zoneId:bill
///
/// Record:
/// private
public struct BillModel: Equatable, Identifiable {
    public var id: String
    
    public var value: Double
    
    public var type: BillType
    
    public var mainCategory: BillMainCategoryModel
    
    public var subCategory: BillSubCategoryModel
    
    public var createdAt: String
    
    public var updatedAt: String
    
    public var createdByUser: UserModel
    
    public var updatedByUser: UserModel
    
    public var description: String
   
    public init(id: String, value: Double, type: BillType, mainCategory: BillMainCategoryModel, subCategory: BillSubCategoryModel, createdAt: String, updatedAt: String, createdByUser: UserModel, updatedByUser: UserModel, description: String) {
        self.id = id
        self.value = value
        self.type = type
        self.mainCategory = mainCategory
        self.subCategory = subCategory
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdByUser = createdByUser
        self.updatedByUser = updatedByUser
        self.description = description
    }
}

/// 账单类别
///
/// Zone:
/// Public
/// zoneId:main_category
///
/// Record:
/// public
public struct BillMainCategoryModel: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let subCategories: [BillSubCategoryModel]
    
    public init(id: String, name: String, subCategories: [BillSubCategoryModel]) {
        self.id = id
        self.name = name
        self.subCategories = subCategories
    }
}

/// 账单子类别
///
/// Zone:
/// public
/// zoneId:sub_category
///
/// Record:
/// public
public struct BillSubCategoryModel: BillSubCategory, Equatable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}


public struct BillSectionData: SectionDataProtocol, Equatable, Identifiable {
    public typealias CellData = BillModel
    
    public typealias HeaderData = String
    
    public typealias FooterData = String

    public var id: String
    
    public var header: String?
    
    public var footer: String?
    
    public var cells: [BillModel]

    public init(id: String, header: String? = nil, footer: String? = nil, cells: [BillModel]) {
        self.id = id
        self.header = header
        self.footer = footer
        self.cells = cells
    }
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
