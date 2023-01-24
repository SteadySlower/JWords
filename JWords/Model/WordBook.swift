//
//  WordBook.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import Foundation

enum WordBookSchedule: CaseIterable {
    case none, study, review
}

protocol WordBook {
    var id: String { get }
    var title: String { get }
    var createdAt: Date { get }
    var closed: Bool { get }
    var dayFromToday: Int { get }
    var schedule: WordBookSchedule { get }
    var preferredFrontType: FrontType { get }
}

struct WordBookImpl: WordBook {
    
    let id: String
    let title: String
    let createdAt: Date
    private let _closed: Bool?
    private let _preferredFrontType: FrontType?
    
    var closed: Bool {
        if let closed = _closed { return closed }
        return false
    }
    
    var preferredFrontType: FrontType {
        if let _preferredFrontType = _preferredFrontType { return _preferredFrontType }
        return .kanji
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
    
    init(id: String, dict: [String: Any]) throws {
        self.id = id
        
        if let title = dict["title"] as? String,
           let createdAt = dict["createdAt"] as? Date
        {
            self.title = title
            self.createdAt = createdAt
        } else {
            throw AppError.Initializer.wordBookImpl
        }
        
        if let _closed = dict["_closed"] as? Bool {
            self._closed = _closed
        } else {
            self._closed = nil
        }
        
        if let rawValue = dict["preferredFrontType"] as? Int,
           let _preferredFrontType = FrontType(rawValue: rawValue) {
            self._preferredFrontType = _preferredFrontType
        } else {
            self._preferredFrontType = nil
        }
    }
}
