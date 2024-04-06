//
//  Kanji.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import Foundation
import CoreData

struct Kanji: Equatable {
    
    let id: String
    let objectID: NSManagedObjectID
    let kanjiText: String
    let meaningText: String
    let ondoku: String
    let kundoku: String
    var studyState: StudyState
    let createdAt: Date
    let usedIn: Int
    
    init(index: Int) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.kanjiText = "漢"
        self.meaningText = "한자\(index)"
        self.ondoku = "かん"
        self.kundoku = "かん"
        self.studyState = StudyState(rawValue: (0..<3).randomElement()!) ?? .undefined
        self.createdAt = Date()
        self.usedIn = index
    }
    
    // initializer for test mocking
    init(
        id: String = UUID().uuidString,
        objectID: NSManagedObjectID = NSManagedObjectID(),
        kanjiText: String,
        meaningText: String,
        ondoku: String,
        kundoku: String,
        studyState: StudyState,
        createdAt: Date,
        usedIn: Int
    ) {
        self.id = id
        self.objectID = objectID
        self.kanjiText = kanjiText
        self.meaningText = meaningText
        self.ondoku = ondoku
        self.kundoku = kundoku
        self.studyState = studyState
        self.createdAt = createdAt
        self.usedIn = usedIn
    }
    
}

extension Array where Element == Kanji {
    static var mock: [Kanji] {
        var result = [Kanji]()
        for i in 0..<10 {
            result.append(Kanji(index: i))
        }
        return result
    }
}
