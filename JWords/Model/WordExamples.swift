//
//  WordExamples.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/30.
//


import FirebaseFirestoreSwift
import Firebase

struct WordExample: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var meaningText: String = ""
    var meaningImageURL: String = ""
    var ganaText: String = ""
    var ganaImageURL: String = ""
    var kanjiText: String = ""
    var kanjiImageURL: String = ""
    let timestamp: Timestamp
    let used: Int
}
