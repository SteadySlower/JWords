//
//  StudyUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData

public enum StudyState: Int, CaseIterable {
    case undefined = 0, success, fail
}

public enum UnitType: Int, CaseIterable {
    case word, kanji, sentence
    
    var description: String {
        switch self {
        case .word: return "단어"
        case .kanji: return "한자"
        case .sentence: return "문장"
        }
    }
}

public struct StudyUnit: Equatable, Identifiable, Hashable {
    
    public let id: String
    public let objectID: NSManagedObjectID
    public let type: UnitType
    public let studySets: [StudySet]
    public let kanjiText: String
    public let kanjiImageID: String?
    public let meaningText: String
    public let meaningImageID: String?
    public var studyState: StudyState
    public let createdAt: Date
    
    public init(
        id: String,
        objectID: NSManagedObjectID,
        type: UnitType,
        studySets: [StudySet],
        kanjiText: String,
        kanjiImageID: String?,
        meaningText: String,
        meaningImageID: String?,
        studyState: StudyState,
        createdAt: Date
    ) {
        self.id = id
        self.objectID = objectID
        self.type = type
        self.studySets = studySets
        self.kanjiText = kanjiText
        self.kanjiImageID = kanjiImageID
        self.meaningText = meaningText
        self.meaningImageID = meaningImageID
        self.studyState = studyState
        self.createdAt = createdAt
    }
    
    // intializer for mocking
    public init(index: Int) {
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
    public init(
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}

public extension Array where Element == StudyUnit {
    static let mock: [StudyUnit] = {
        var result = [StudyUnit]()
        for i in 0..<10 {
            result.append(StudyUnit(index: i))
        }
        return result
    }()
}
