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
    let createdAt: Date
    let usedIn: Int
    
    init(from mo: StudyKanjiMO) {
        self.id = mo.id ?? UUID().uuidString
        self.objectID = mo.objectID
        self.kanjiText = mo.kanji ?? ""
        self.meaningText = mo.meaning ?? ""
        self.ondoku = mo.ondoku ?? ""
        self.kundoku = mo.kundoku ?? ""
        self.createdAt = mo.createdAt ?? Date()
        self.usedIn = mo.words?.count ?? 0
    }
    
    init(index: Int) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.kanjiText = "漢"
        self.meaningText = "한자\(index)"
        self.ondoku = "かん"
        self.kundoku = "かん"
        self.createdAt = Date()
        self.usedIn = index
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
