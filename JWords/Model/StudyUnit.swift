//
//  StudyUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData

enum UnitType: Int, CaseIterable {
    case word, kanji, sentence
    
    var description: String {
        switch self {
        case .word: return "단어"
        case .kanji: return "한자"
        case .sentence: return "문장"
        }
    }
}

struct StudyUnit: Equatable, Identifiable {
    
    let id: String
    let objectID: NSManagedObjectID
    let type: UnitType
    let studySets: [StudySet]
    let kanjiText: String?
    let kanjiImageID: String?
    let meaningText: String?
    let meaningImageID: String?
    var studyState: StudyState
    let createdAt: Date
    
    init(from mo: StudyUnitMO) {
        self.id = mo.id ?? ""
        self.objectID = mo.objectID
        self.type = UnitType(rawValue: Int(mo.type)) ?? .word
        self.kanjiText = mo.kanjiText
        self.kanjiImageID = mo.kanjiImageID
        self.meaningText = mo.meaningText
        self.meaningImageID = mo.meaningImageID
        self.studyState = StudyState(rawValue: Int(mo.studyState)) ?? .undefined
        self.createdAt = mo.createdAt ?? Date()
        self.studySets = mo.set?.array.compactMap { $0 as? StudySetMO }.map { StudySet(from: $0) } ?? []
    }
    
}
