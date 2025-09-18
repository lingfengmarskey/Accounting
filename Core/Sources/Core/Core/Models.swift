//
//  s.swift
//  
//
//  Created by Marcos Meng on 2022/08/04.
//
import CloudKit
import CoreData
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
public struct AccountBook: Equatable, Identifiable {
    public var owner: User
    
    public var participacer: [Participacer]
    
    public var bills: [Bill]
    
    public var id: String
    public var name: String
    public var createdAt: String
    
    public init(owner: User, participacer: [Participacer], bills: [Bill], id: String, name: String, createdAt: String) {
        self.owner = owner
        self.participacer = participacer
        self.bills = bills
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}

public extension AccountBook {
    static let none = AccountBook(
        owner: .none,
        participacer: [],
        bills: [],
        id: "",
        name: "",
        createdAt: ""
    )
}

public struct User: Equatable, Identifiable, UserProtocol {
    public var id: String
    public var name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public extension User {
    static let none = User(id: "", name: "")
}

public struct Participacer: Equatable, Identifiable, UserProtocol {
    public var permission: Permission
    public var id: String
    public var name: String
    
    public init(permission: Permission, id: String, name: String) {
        self.permission = permission
        self.id = id
        self.name = name
    }
}

public extension Participacer {
    static let none = Participacer(permission: .read, id: "", name: "")
    static func from(_ user: UserEntity, permission: Permission) -> Participacer? {
        guard let userId = user.id, let name = user.name else { return nil }
        return .init(permission: permission, id: userId.uuidString, name: name)
    }
}

public extension [Participacer] {
    static func from(_ users: Set<UserEntity>, permission: Permission) -> [Participacer] {
        return users.compactMap { Participacer.from($0, permission: permission) }
    }
}

public extension NSSet {
    func convertToParticipacers(permission: Permission) -> [Participacer] {
        guard let source = self as? Set<UserEntity> else { return [] }
        return source.compactMap { entity in
            Participacer.from(entity, permission: permission)
        }
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
public struct Bill: Equatable, Identifiable {
    public var id: String
    public var value: Double
    public var type: BillType
    public var mainCategory: BillMainCategory
    public var subCategory: BillSubCategory
    public var createdAt: String
    public var updatedAt: String
    public var createdByUser: User
    public var updatedByUser: User
    public var description: String
   
    public init(id: String, value: Double, type: BillType, mainCategory: BillMainCategory, subCategory: BillSubCategory, createdAt: String, updatedAt: String, createdByUser: User, updatedByUser: User, description: String) {
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

public extension Bill {
    static let none = Bill(
        id: "",
        value: 0,
        type: .payment,
        mainCategory: .none,
        subCategory: .none,
        createdAt: "",
        updatedAt: "",
        createdByUser: .none,
        updatedByUser: .none,
        description: ""
    )
}

/// 账单类别
///
/// Zone:
/// Public
/// zoneId:main_category
///
/// Record:
/// public
public struct BillMainCategory: Equatable, Identifiable {
    public let id: String
    public let name: String
    public let subCategories: [BillSubCategory]
    
    public init(id: String, name: String, subCategories: [BillSubCategory]) {
        self.id = id
        self.name = name
        self.subCategories = subCategories
    }
}

public extension BillMainCategory {
    static let none = BillMainCategory(id: "", name: "", subCategories: [])
}

/// 账单子类别
///
/// Zone:
/// public
/// zoneId:sub_category
///
/// Record:
/// public
public struct BillSubCategory: Equatable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public extension BillSubCategory {
    static let none = BillSubCategory(id: "", name: "")
}

public struct CurrencyModel: Equatable, Identifiable {
    public var recordName: String
    public var shortName: String
    public var fullName: String
    public var rate: Double
    public var modifiedAt: Date

    public var id: String { recordName }

    public init(recordName: String, shortName: String, fullName: String, rate: Double, modifiedAt: Date) {
        self.recordName = recordName
        self.shortName = shortName
        self.fullName = fullName
        self.rate = rate
        self.modifiedAt = modifiedAt
    }
}

public extension CurrencyModel {
    static let usd = CurrencyModel(
        recordName: "USD",
        shortName: "USD",
        fullName: "United States Dollar",
        rate: 1,
        modifiedAt: .distantPast
    )
    static let none = CurrencyModel(
        recordName: "",
        shortName: "",
        fullName: "",
        rate: 0,
        modifiedAt: .distantPast
    )
}

public extension CurrencyModel {
    init?(entity: CurrencyEntity) {
        guard let recordName = entity.recordName,
              let shortName = entity.shortName,
              let fullName = entity.fullName
        else { return nil }

        let modifiedAt = entity.modifiedAt ?? .distantPast
        self.init(
            recordName: recordName,
            shortName: shortName,
            fullName: fullName,
            rate: entity.rate,
            modifiedAt: modifiedAt
        )
    }

    init?(record: CKRecord) {
        guard let shortName = record["shortName"] as? String,
              let fullName = record["fullName"] as? String,
              let rate = record["rate"] as? Double
        else { return nil }

        let modifiedAt = record.modificationDate ?? record.creationDate ?? .distantPast
        self.init(
            recordName: record.recordID.recordName,
            shortName: shortName,
            fullName: fullName,
            rate: rate,
            modifiedAt: modifiedAt
        )
    }

    func apply(to entity: CurrencyEntity) {
        entity.recordName = recordName
        entity.shortName = shortName
        entity.fullName = fullName
        entity.rate = rate
        entity.modifiedAt = modifiedAt
    }

    func makeRecord(existingRecord: CKRecord? = nil) -> CKRecord {
        let record: CKRecord
        if let existingRecord {
            record = existingRecord
        } else {
            let recordID = CKRecord.ID(recordName: recordName)
            record = CKRecord(recordType: "Currency", recordID: recordID)
        }
        record["shortName"] = shortName as CKRecordValue
        record["fullName"] = fullName as CKRecordValue
        record["rate"] = NSNumber(value: rate)
        return record
    }
}

public extension CurrencyEntity {
    func toModel() -> CurrencyModel? {
        CurrencyModel(entity: self)
    }
}

public extension CKRecord {
    func toCurrencyModel() -> CurrencyModel? {
        CurrencyModel(record: self)
    }
}

public struct BillSectionData: SectionDataProtocol, Equatable, Identifiable {
    public typealias CellData = Bill
    public typealias HeaderData = String
    public typealias FooterData = String

    public var id: String
    public var header: String?
    public var footer: String?
    public var cells: [Bill]

    public init(id: String, header: String? = nil, footer: String? = nil, cells: [Bill]) {
        self.id = id
        self.header = header
        self.footer = footer
        self.cells = cells
    }
}

public extension BillSectionData {
    static let none = BillSectionData(id: "", header: nil, footer: nil, cells: [])
}

/**
 open class Participant : NSObject, NSSecureCoding, NSCopying {

     
     @NSCopying open var userIdentity: CKUserIdentity { get }

     
     /** The default participant role is @c CKShareParticipantRolePrivateUser. */
     @available(iOS 12.0, *)
     open var role: CKShare.ParticipantRole

     
     /** The default participant type is @c CKShare.ParticipantTypePrivateUser. */
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

