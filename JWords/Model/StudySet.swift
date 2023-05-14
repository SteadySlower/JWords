//
//  StudySet.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData

struct StudySet: Equatable, Identifiable {
    
    let id: String
    let objectID: NSManagedObjectID
    let title: String
    let createdAt: Date
    let closed: Bool
    let preferredFrontType: FrontType
    let isAutoSchedule: Bool
    
    init(from mo: StudySetMO) {
        self.id = mo.id ?? ""
        self.objectID = mo.objectID
        self.title = mo.title ?? ""
        self.createdAt = mo.createdAt ?? Date()
        self.closed = mo.closed
        self.preferredFrontType = FrontType(rawValue: Int(mo.preferredFrontType)) ?? .kanji
        self.isAutoSchedule = mo.isAutoSchedule
    }
    
    // intializer for mocking
    init(index: Int) {
        self.id = "\(index)"
        self.objectID = NSManagedObjectID()
        self.title = "\(index)번 단어장"
        self.createdAt = Date()
        self.closed = false
        self.preferredFrontType = .kanji
        self.isAutoSchedule = true
    }
    
    var dayFromToday: Int {
        return Calendar.current.getDateGap(from: self.createdAt, to: Date())
    }
    
    var schedule: WordBookSchedule {
        let dayFromToday = self.dayFromToday
        let reviewInterval = [3, 7, 14, 28]
        
        if dayFromToday >= 0 && dayFromToday < 3 {
            return .study
        } else if reviewInterval.contains(dayFromToday) {
            return .review
        } else {
            return .none
        }
    }
    
}
