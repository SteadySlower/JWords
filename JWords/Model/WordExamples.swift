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

struct WordExampleInput {
    let meaningText: String
    let meaningImageURL: String
    let ganaText: String
    let ganaImageURL: String
    let kanjiText: String
    let kanjiImageURL: String
    let timestamp: Timestamp = Timestamp(date: Date())
    let used: Int = 0
    
    init(from word: Word) {
        self.meaningText = word.meaningText
        self.meaningImageURL = word.meaningImageURL
        self.ganaText = word.ganaText
        self.ganaImageURL = word.ganaImageURL
        self.kanjiText = word.kanjiText
        self.kanjiImageURL = word.kanjiImageURL
    }
}
