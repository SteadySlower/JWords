//
//  StudySet.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData

enum FrontType: Int, Equatable, Hashable, CaseIterable {
    case kanji
    case meaning
    
    var pickerText: String {
        switch self {
        case .meaning:
            return "한"
        case .kanji:
            return "漢"
        }
    }
    
    var preferredTypeText: String {
        switch self {
        case .meaning: return "뜻 앞면"
        case .kanji: return "일본어 앞면"
        }
    }
}

enum SetSchedule: Equatable, CaseIterable {
    case none, study, review
}

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
    
    var schedule: SetSchedule {
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

extension Array where Element == StudySet {
    static var mock: [StudySet] {
        var result = [StudySet]()
        for i in 0..<10 {
            result.append(StudySet(index: i))
        }
        return result
    }
}
