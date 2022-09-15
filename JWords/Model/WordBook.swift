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
    
    // TODO: Handle Parsing Error
    init(id: String, dict: [String: Any]) {
        self.id = id
        self.title = dict["title"] as? String ?? ""
        self.createdAt = dict["createdAt"] as? Date ?? Date()
        self._closed = dict["_closed"] as? Bool ?? false
    }
}
