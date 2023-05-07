//
//  StudySet.swift
//  JWords
//
//  Created by JW Moon on 2023/05/05.
//

import Foundation

struct StudySet: Equatable, Identifiable {
    
    let id: String
    let title: String
    let createdAt: Date
    let closed: Bool
    let preferredFrontType: FrontType
    let isAutoSchedule: Bool
    
    init(from mo: StudySetMO) {
        self.id = mo.id ?? ""
        self.title = mo.title ?? ""
        self.createdAt = mo.createdAt ?? Date()
        self.closed = mo.closed
        self.preferredFrontType = FrontType(rawValue: Int(mo.preferredFrontType)) ?? .kanji
        self.isAutoSchedule = mo.isAutoSchedule
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
