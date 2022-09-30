//
//  MockSample.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/29.
//

@testable import JWords
import Foundation

struct MockSample: Sample {
    let id: String
    let meaningText: String
    let meaningImageURL: String
    let ganaText: String
    let ganaImageURL: String
    let kanjiText: String
    let kanjiImageURL: String
    let createdAt: Date
    let used: Int
    let hasImage: Bool
    
    init(
        id: String = UUID().uuidString,
        meaningText: String = Random.string,
        meaningImageURL: String = "",
        ganaText: String = Random.string,
        ganaImageURL: String = "",
        kanjiText: String = Random.string,
        kanjiImageURL: String = "",
        createdAt: Date = Random.dateWithinYear,
        used: Int = Random.int(from: 0, to: 10),
        hasImage: Bool = false
    ) {
        self.id = id
        self.meaningText = meaningText
        self.meaningImageURL = meaningImageURL
        self.ganaText = ganaText
        self.ganaImageURL = ganaImageURL
        self.kanjiText = kanjiText
        self.kanjiImageURL = kanjiImageURL
        self.createdAt = createdAt
        self.used = used
        self.hasImage = hasImage
    }
}
