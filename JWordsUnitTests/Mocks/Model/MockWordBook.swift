//
//  WordBook.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 2022/09/28.
//

@testable import JWords
import Foundation

struct MockWordBook: WordBook {
    let id: String
    let title: String
    let createdAt: Date
    let closed: Bool
    let dayFromToday: Int
    let schedule: WordBookSchedule
    
    init(
        id: String = UUID().uuidString,
        title: String = Random.string,
        createdAt: Date = Random.dateWithinYear,
        closed: Bool = Random.bool,
        dayFromToday: Int = Random.int(from: 0, to: 100),
        schedule: WordBookSchedule = WordBookSchedule.allCases.randomElement() ?? .none
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.closed = closed
        self.dayFromToday = dayFromToday
        self.schedule = schedule
    }
}

