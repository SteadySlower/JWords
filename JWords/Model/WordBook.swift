//
//  WordBook.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import FirebaseFirestoreSwift
import Firebase


struct WordBook: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var title: String
    var words: [Word]?
    let timestamp: Timestamp
}
