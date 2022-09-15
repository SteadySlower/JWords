//
//  Word.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Foundation

enum StudyState: Int {
    case undefined = 0, success, fail
}

protocol Word {
    var id: String { get }
    var wordBookID: String { get }
    var meaningText: String { get }
    var meaningImageURL: String { get }
    var ganaText: String { get }
    var ganaImageURL: String { get }
    var kanjiText: String { get }
    var kanjiImageURL: String { get }
    var studyState: StudyState { get set }
    var timestamp: Date { get }
    var hasImage: Bool { get }
}

struct WordImpl: Word {
   
    let id: String
    let wordBookID: String
    let meaningText: String
    let meaningImageURL: String
    let ganaText: String
    let ganaImageURL: String
    let kanjiText: String
    let kanjiImageURL: String
    var studyState: StudyState
    let timestamp: Date
    
    var hasImage: Bool {
        !self.meaningImageURL.isEmpty || !self.ganaImageURL.isEmpty || !self.kanjiImageURL.isEmpty
    }
    
    // TODO: Handle Parsing Error
    init(id: String, wordBookID: String, dict: [String : Any]) {
        self.id = id
        self.wordBookID = wordBookID
        self.meaningText = dict["meaningText"] as? String ?? ""
        self.meaningImageURL = dict["meaningImageURL"] as? String ?? ""
        self.ganaText = dict["ganaText"] as? String ?? ""
        self.ganaImageURL = dict["ganaImageURL"] as? String ?? ""
        self.kanjiText = dict["kanjiText"] as? String ?? ""
        self.kanjiImageURL = dict["kanjiImageURL"] as? String ?? ""
        let rawValue = dict["studyState"] as? Int ?? 0
        self.studyState = StudyState(rawValue: rawValue) ?? .undefined
        self.timestamp = dict["timestamp"] as? Date ?? Date()
    }
}


