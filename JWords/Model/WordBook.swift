//
//  WordBook.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import FirebaseFirestoreSwift
import Firebase

protocol WordBook {
    var id: String? { get }
    var title: String { get }
    var timestamp: Timestamp { get }
    var closed: Bool { get }
}

struct WordBookImpl: WordBook, Codable, Hashable {
    
    @DocumentID var id: String?
    var title: String
    let timestamp: Timestamp
    private let _closed: Bool?
    
    var closed: Bool {
        if let closed = _closed { return closed }
        return false
    }
}
