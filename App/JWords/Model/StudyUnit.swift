//
//  StudyUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData

enum StudyState: Int, CaseIterable {
    case undefined = 0, success, fail
}

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

struct StudyUnit: Equatable, Identifiable, Hashable {
    
    let id: String
    let objectID: NSManagedObjectID
    let type: UnitType
    let studySets: [StudySet]
    let kanjiText: String
    let kanjiImageID: String?
    let meaningText: String
    let meaningImageID: String?
    var studyState: StudyState
    let createdAt: Date
    
    init(from mo: StudyUnitMO) {
        self.id = mo.id ?? ""
        self.objectID = mo.objectID
        self.type = UnitType(rawValue: Int(mo.type)) ?? .word
        self.kanjiText = mo.kanjiText ?? ""
        self.kanjiImageID = mo.kanjiImageID
        self.meaningText = mo.meaningText ?? ""
        self.meaningImageID = mo.meaningImageID
        self.studyState = StudyState(rawValue: Int(mo.studyState)) ?? .undefined
        self.createdAt = mo.createdAt ?? Date()
        self.studySets = mo.set?.compactMap { $0 as? StudySetMO }.map { StudySet(from: $0) } ?? []
    }
    
    // intializer for mocking
    init(index: Int) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.type = UnitType.allCases.randomElement()!
        self.studySets = []
        self.kanjiText = "感動\(index)⌜かんどう⌟`"
        self.kanjiImageID = nil
        self.meaningText = "Meaning Text \(index)"
        self.meaningImageID = nil
        self.studyState = .undefined
        self.createdAt = Date()
    }
    
    // initialzer for test mocking
    init(
        id: String = UUID().uuidString,
        type: UnitType = .allCases.randomElement()!,
        kanjiText: String,
        kanjiImageID: String? = nil,
        meaningText: String,
        maeaningImageID: String? = nil,
        studyState: StudyState,
        studySets: [StudySet],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.objectID = NSManagedObjectID()
        self.type = type
        self.kanjiText = kanjiText
        self.kanjiImageID = nil
        self.meaningText = meaningText
        self.meaningImageID = nil
        self.studyState = studyState
        self.studySets = studySets
        self.createdAt = createdAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

extension Array where Element == StudyUnit {
    static let mock: [StudyUnit] = {
        var result = [StudyUnit]()
        for i in 0..<10 {
            result.append(StudyUnit(index: i))
        }
        return result
    }()
}
