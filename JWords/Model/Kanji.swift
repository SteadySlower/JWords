//
//  Kanji.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import Foundation
import CoreData

struct Kanji: Equatable {
    
    let objectID: NSManagedObjectID
    let kanjiText: String
    let meaningText: String
    let ondoku: String
    let kundoku: String
    let createdAt: Date
    let usedIn: Int
    
    init(from mo: StudyUnitMO) {
        self.objectID = mo.objectID
        self.kanjiText = mo.kanjiText ?? ""
        self.meaningText = mo.meaningText ?? ""
        self.ondoku = ""
        self.kundoku = ""
        self.createdAt = mo.createdAt ?? Date()
        self.usedIn = mo.sampleForKanji?.count ?? 0
    }
    
    init(from mo: StudyKanjiMO) {
        self.objectID = mo.objectID
        self.kanjiText = mo.kanji ?? ""
        self.meaningText = mo.meaning ?? ""
        self.ondoku = mo.ondoku ?? ""
        self.kundoku = mo.kundoku ?? ""
        self.createdAt = mo.createdAt ?? Date()
        self.usedIn = mo.words?.count ?? 0
    }
    
}
