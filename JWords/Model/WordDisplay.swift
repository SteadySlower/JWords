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
    
    var toggleButtonTitle: String {
        switch self {
        case .meaning:
            return "漢"
        case .kanji:
            return "한"
        }
    }
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
    
    var frontImageURLs: [String] {
        switch frontType {
        case .meaning:
            return [word.meaningImageURL].filter { $0.isEmpty }
        case .kanji:
            return [word.kanjiImageURL].filter { $0.isEmpty }
        }
    }
    
    var backText: String {
        switch frontType {
        case .meaning:
            let changeLine = (!word.ganaText.isEmpty && !word.kanjiText.isEmpty) ? "\n" : ""
            return "\(word.ganaText)\(changeLine)\(word.kanjiText)"
        case .kanji:
            let changeLine = (!word.ganaText.isEmpty && !word.meaningText.isEmpty) ? "\n" : ""
            return "\(word.ganaText)\(changeLine)\(word.meaningText)"
        }
    }
    
    var backImages: [String] {
        switch frontType {
        case .meaning:
            return [word.kanjiImageURL, word.ganaImageURL].filter { $0.isEmpty }
        case .kanji:
            return [word.ganaImageURL, word.meaningImageURL].filter { $0.isEmpty }
        }
    }
    
    var hasImage: Bool {
        return !word.meaningImageURL.isEmpty || !word.ganaImageURL.isEmpty || !word.kanjiImageURL.isEmpty
    }
}
