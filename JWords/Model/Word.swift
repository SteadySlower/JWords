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

//protocol Word: Equatable {
//    var id: String { get }
//    var wordBookID: String { get }
//    var meaningText: String { get }
//    var meaningImageURL: String { get }
//    var ganaText: String { get }
//    var ganaImageURL: String { get }
//    var kanjiText: String { get }
//    var kanjiImageURL: String { get }
//    var studyState: StudyState { get set }
//    var createdAt: Date { get }
//
//    var hasImage: Bool { get }
//}

struct Word: Equatable, Identifiable, Sendable {
   
    let id: String
    let wordBookID: String
    let meaningText: String
    let meaningImageURL: String
    let ganaText: String
    let ganaImageURL: String
    let kanjiText: String
    let kanjiImageURL: String
    var studyState: StudyState
    let createdAt: Date
    
    var hasImage: Bool {
        !self.meaningImageURL.isEmpty || !self.ganaImageURL.isEmpty || !self.kanjiImageURL.isEmpty
    }
    
    // interim init for development
    init(index: Int = 0) {
        self.id = UUID().uuidString
        self.wordBookID = UUID().uuidString
        self.meaningText = "의미\(index)"
        self.meaningImageURL = ""
        self.ganaText = "가나\(index)"
        self.ganaImageURL = ""
        self.kanjiText = "한자\(index)"
        self.kanjiImageURL = "https://firebasestorage.googleapis.com:443/v0/b/jwords-935a2.appspot.com/o/card_images%2FA76BE9AC-C849-45DA-95C5-77AF39D5F096?alt=media&token=27225755-b7ab-4197-a5a1-f604b4b4f3c1"
        self.studyState = .undefined
        self.createdAt = Date()
    }
    
    init(id: String,
        wordBookID: String,
        meaningText: String,
        meaningImageURL: String,
        ganaText: String,
        ganaImageURL: String,
        kanjiText: String,
        kanjiImageURL: String,
        studyState: StudyState,
        createdAt: Date) {
        self.id = id
        self.wordBookID = wordBookID
        self.meaningText = meaningText
        self.meaningImageURL = meaningImageURL
        self.ganaText = ganaText
        self.ganaImageURL = ganaImageURL
        self.kanjiText = kanjiText
        self.kanjiImageURL = kanjiImageURL
        self.studyState = studyState
        self.createdAt = createdAt
    }
    
    init(id: String, wordBookID: String, dict: [String : Any]) throws {
        self.id = id
        self.wordBookID = wordBookID
        
        if let meaningText = dict["meaningText"] as? String,
           let meaningImageURL = dict["meaningImageURL"] as? String,
           let ganaText = dict["ganaText"] as? String,
           let ganaImageURL = dict["ganaImageURL"] as? String,
           let kanjiText = dict["kanjiText"] as? String,
           let kanjiImageURL = dict["kanjiImageURL"] as? String,
           let rawValue = dict["studyState"] as? Int,
           let studyState = StudyState(rawValue: rawValue),
           let createdAt = dict["createdAt"] as? Date
        {
            self.meaningText = meaningText
            self.meaningImageURL = meaningImageURL
            
            // 가나만 있으면 가나가 한자의 자리로 오도록 수정
            if kanjiText.isEmpty && !ganaText.isEmpty {
                self.kanjiText = ganaText
                self.ganaText = ""
            } else {
                self.ganaText = ganaText
                self.kanjiText = kanjiText
            }
            
            self.ganaImageURL = ganaImageURL
            self.kanjiImageURL = kanjiImageURL
            self.studyState = studyState
            self.createdAt = createdAt
            

        } else {
            throw AppError.Initializer.wordImpl
        }
    }
}


