//
//  StudyUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation

enum UnitType: CaseIterable {
    case word, kanji, sentence
    
    var description: String {
        switch self {
        case .word: return "단어"
        case .kanji: return "한자"
        case .sentence: return "문장"
        }
    }
}

struct StudyUnit: Equatable, Identifiable, Sendable {
    
    let id: String
    let type: UnitType
    let studySetID: String
    let kanjiText: String
    let kanjiImageURL: String
    let meaningText: String
    let meaningImageURL: String
    var studyState: StudyState
    let createdAt: Date
    
}
