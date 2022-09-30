//
//  MockWord.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/30.
//

@testable import JWords
import Foundation

struct MockWord: Word {
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
    let hasImage: Bool
    
    init(
        id: String = UUID().uuidString,
        wordBookID: String = UUID().uuidString,
        meaningText: String = Random.string,
        meaningImageURL: String = "",
        ganaText: String = Random.string,
        ganaImageURL: String = "",
        kanjiText: String = Random.string,
        kanjiImageURL: String = "",
        studyState: StudyState = .undefined,
        createdAt: Date = Random.dateWithinYear,
        hasImage: Bool = false
    ) {
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
        self.hasImage = hasImage
    }
    
}
