//
//  DataManager.swift
//
//
//  Created by Marcos Meng on 2024/01/29.
//

import Foundation


protocol RecordDataProtocol {
    // TODO: add real variables
}

/// Data fetch from local and api
protocol DataManagerProtocol {
    // MARK: - Books
    
    func createBook(userId: String, date: Date, title: String) async throws -> Result<String, Error> // return book id
    func removeBook(userId: String, bookId: String) async throws -> Result<String, Error> // return book id
    func updateBook(userId: String, bookId: String) async throws -> Result<String, Error> // return book id
    
    /// fetch latest books from specific date to latest time in server
    /// - Parameters:
    ///   - userId: user id
    ///   - from: last fetch date time
    /// - Returns: books IDs
    func fetchBooks(userId: String, from: Date) async throws -> Result<[String], Error>
    
    func invite(on bookId: String, from userId: String, to userIDs: [String]) async throws -> Result<String, Error>
    func removeMember(on bookId: String, userId: String, memberId: [String]) async throws -> Result<String, Error>
    func fetchAllMembers(on bookId: String, userId: String) async throws -> Result<[String], Error>
    
    func addRecord(on bookId: String, from userId: String, record: RecordDataProtocol) async throws -> Result<String, Error> // return record id
    func removeRecord(on bookId: String, from userId: String, recordId: String) async throws -> Result<String, Error>
    func updateRecord(on bookId: String, from userId: String, recordId: RecordDataProtocol) async throws -> Result<String, Error>
    func fetchRecords(on bookId: String, from userId: String) async throws -> Result<[String], Error>   // return record IDs
    
    func subscribeBookRecords(on bookId: String, from userId: String) async throws -> Result<RecordDataProtocol, Error>
    // TODO: update here
    func subscribeBook(on bookId: String, from userId: String) async throws -> Result<[String], Error>
    
}

struct DataManager {
    static let shared = DataManager()
}
