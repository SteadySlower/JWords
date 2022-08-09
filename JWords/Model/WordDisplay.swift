//
//  WordDisplay.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/08/09.
//

import Foundation

enum FrontType {
    case meaning
    case kanji
}

struct WordDisplay {
    let wordBook: WordBook
    var word: Word
    var frontType: FrontType
    var isFront: Bool = true
    
    var frontText: String {
        switch frontType {
        case .meaning:
            return word.meaningText
        case .kanji:
            return word.kanjiText
        }
    }
    
    var frontImageURL: String {
        switch frontType {
        case .meaning:
            return word.meaningImageURL
        case .kanji:
            return word.kanjiImageURL
        }
    }
    
    var backText: String {
        switch frontType {
        case .meaning:
            return "\(word.ganaText)\n\(word.kanjiText)"
        case .kanji:
            return "\(word.ganaText)\n\(word.meaningText)"
        }
    }
    
    var backImages: [String] {
        switch frontType {
        case .meaning:
            return [word.kanjiImageURL, word.ganaImageURL]
        case .kanji:
            return [word.ganaImageURL, word.meaningImageURL]
        }
    }
}
