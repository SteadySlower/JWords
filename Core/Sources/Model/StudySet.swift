//
//  StudySet.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation
import CoreData
import Util
import SwiftUI

public enum FrontType: Int, Equatable, Hashable, CaseIterable {
    case kanji
    case meaning
    
    public var pickerText: String {
        switch self {
        case .meaning:
            return "한"
        case .kanji:
            return "漢"
        }
    }
    
    public var preferredTypeText: String {
        switch self {
        case .meaning: return "뜻 앞면"
        case .kanji: return "일본어 앞면"
        }
    }
}

public enum SetSchedule: Equatable, CaseIterable {
    case none, study, review
    
    public var labelColor: Color {
        switch self {
        case .none: return .black
        case .study: return .blue
        case .review: return .pink
        }
    }
}

public struct StudySet: Equatable, Identifiable, Hashable {
    
    public let id: String
    public let objectID: NSManagedObjectID
    public let title: String
    public let createdAt: Date
    public let closed: Bool
    public let preferredFrontType: FrontType
    public let isAutoSchedule: Bool
    
    public init(
        id: String,
        objectID: NSManagedObjectID,
        title: String,
        createdAt: Date,
        closed: Bool,
        preferredFrontType: FrontType,
        isAutoSchedule: Bool
    ) {
        self.id = id
        self.objectID = objectID
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.preferredFrontType = preferredFrontType
        self.isAutoSchedule = isAutoSchedule
    }
    
    public init(title: String) {
        self.id = title
        self.objectID = NSManagedObjectID()
        self.title = title
        self.createdAt = Date()
        self.closed = false
        self.preferredFrontType = .kanji
        self.isAutoSchedule = true
    }
    
    // intializer for mocking
    public init(
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
    public init(title: String, createdAt: Date, closed: Bool) {
        self.id = UUID().uuidString
        self.objectID = NSManagedObjectID()
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.preferredFrontType = [.kanji, .meaning].randomElement()!
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

public extension Array where Element == StudySet {
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
