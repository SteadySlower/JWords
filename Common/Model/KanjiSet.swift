//
//  KanjiSet.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import Foundation
import CoreData

public struct KanjiSet: Equatable, Identifiable, Hashable {
    
    public let id: String
    public let objectID: NSManagedObjectID
    public let title: String
    public let createdAt: Date
    public let closed: Bool
    public let isAutoSchedule: Bool
    
    public init(
        id: String,
        objectID: NSManagedObjectID,
        title: String,
        createdAt: Date,
        closed: Bool,
        isAutoSchedule: Bool
    ) {
        self.id = id
        self.objectID = objectID
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.isAutoSchedule = isAutoSchedule
    }
    
    // intializer for mocking
    public init(
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
    public init(title: String, createdAt: Date, closed: Bool) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.isAutoSchedule = true
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public var dayFromToday: Int {
        return Calendar.current.getDateGap(from: self.createdAt, to: Date())
    }
    
    public var schedule: SetSchedule {
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

public extension Array where Element == KanjiSet {
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
