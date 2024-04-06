//
//  KanjiSet.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import Foundation
import CoreData

struct KanjiSet: Equatable, Identifiable, Hashable {
    
    let id: String
    let objectID: NSManagedObjectID
    let title: String
    let createdAt: Date
    let closed: Bool
    let isAutoSchedule: Bool
    
    init(from mo: StudyKanjiSetMO) {
        self.id = mo.id ?? ""
        self.objectID = mo.objectID
        self.title = mo.title ?? ""
        self.createdAt = mo.createdAt ?? Date()
        self.closed = mo.closed
        self.isAutoSchedule = mo.isAutoSchedule
    }
    
    // intializer for mocking
    init(
        index: Int,
        closed: Bool = false,
        setSchedule: SetSchedule = .study
    ) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.title = "\(index)번 한자쓰기장"
        self.createdAt = {
            switch setSchedule {
            case .none:
                return .dateFromToday(99)
            case .study:
                return .dateFromToday(0)
            case .review:
                return .dateFromToday(3)
            }
        }()
        self.closed = closed
        self.isAutoSchedule = true
    }
    
    // initializer for test mocking
    init(title: String, createdAt: Date, closed: Bool) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.isAutoSchedule = true
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
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

extension Array where Element == KanjiSet {
    static let mock: [KanjiSet] = {
        var result = [KanjiSet]()
        for i in 0..<10 {
            result.append(KanjiSet(index: i))
        }
        return result
    }()
    
    static let mockIncludingClosed: [KanjiSet] = {
        var result = [KanjiSet]()
        for i in 0..<10 {
            result.append(KanjiSet(index: i))
        }
        for i in 11..<20 {
            result.append(KanjiSet(index: i, closed: true))
        }
        return result
    }()
}
