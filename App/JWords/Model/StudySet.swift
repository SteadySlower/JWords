//
//  StudySet.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData
import Model

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

//enum SetSchedule: Equatable, CaseIterable {
//    case none, study, review
//}

struct StudySet: Equatable, Identifiable, Hashable {
    
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
    
    init(title: String) {
        self.id = title
        self.objectID = NSManagedObjectID()
        self.title = title
        self.createdAt = Date()
        self.closed = false
        self.preferredFrontType = .kanji
        self.isAutoSchedule = true
    }
    
    // intializer for mocking
    init(
        index: Int,
        closed: Bool = false,
        setSchedule: SetSchedule = .study
    ) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.title = "\(index)번 단어장"
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
        self.preferredFrontType = .kanji
        self.isAutoSchedule = true
    }
    
    // initializer for test mocking
    init(title: String, createdAt: Date, closed: Bool) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.preferredFrontType = [.kanji, .meaning].randomElement()!
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

extension Array where Element == StudySet {
    static let mock: [StudySet] = {
        var result = [StudySet]()
        for i in 0..<10 {
            result.append(StudySet(index: i))
        }
        return result
    }()
    
    static let mockIncludingClosed: [StudySet] = {
        var result = [StudySet]()
        for i in 0..<10 {
            result.append(StudySet(index: i))
        }
        for i in 11..<20 {
            result.append(StudySet(index: i, closed: true))
        }
        return result
    }()
}
