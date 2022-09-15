//
//  WordBook.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Foundation

protocol WordBook {
    var id: String { get }
    var title: String { get }
    var createdAt: Date { get }
    var closed: Bool { get }
}

struct WordBookImpl: WordBook {
    
    let id: String
    let title: String
    let createdAt: Date
    private let _closed: Bool?
    
    var closed: Bool {
        if let closed = _closed { return closed }
        return false
    }
    
    init(id: String, dict: [String: Any]) throws {
        self.id = id
        
        if let title = dict["title"] as? String,
           let createdAt = dict["createdAt"] as? Date
        {
            self.title = title
            self.createdAt = createdAt
        } else {
            throw AppError.Initializer.wordBookImpl
        }
        
        if let _closed = dict["_closed"] as? Bool {
            self._closed = _closed
        } else {
            self._closed = nil
        }
    }
}
