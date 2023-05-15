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
    let kanjiText: String?
    let kanjiImageID: String?
    let meaningText: String?
    let meaningImageID: String?
    let createdAt: Date
    let usedIn: Int
    
    init(from mo: StudyUnitMO) {
        self.id = mo.id ?? ""
        self.objectID = mo.objectID
        self.kanjiText = mo.kanjiText
        self.kanjiImageID = mo.kanjiImageID
        self.meaningText = mo.meaningText
        self.meaningImageID = mo.meaningImageID
        self.createdAt = mo.createdAt ?? Date()
        self.usedIn = mo.sampleForKanji?.count ?? 0
    }
    
}
