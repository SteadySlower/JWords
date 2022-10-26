//
//  TodayBooks.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/10/25.
//

import Foundation

protocol TodayBooks {
    var studyIDs: [String] { get }
    var reviewIDs: [String] { get }
    var reviewedIDs: [String] { get }
    var createdAt: Date { get }
}

struct TodayBooksImpl: TodayBooks {
    let studyIDs: [String]
    let reviewIDs: [String]
    let reviewedIDs: [String]
    let createdAt: Date
    
    init(studyIDs: [String], reviewIDs: [String], reviewedIDs: [String], createdAt: Date) {
        self.studyIDs = studyIDs
        self.reviewIDs = reviewIDs
        self.reviewedIDs = reviewedIDs
        self.createdAt = createdAt
    }
    
    init(dict: [String: Any]) throws {
        
        if let studyIDs = dict["studyIDs"] as? [String],
           let reviewIDs = dict["reviewIDs"] as? [String],
           let reviewedIDs = dict["reviewIDs"] as? [String],
           let createdAt = dict["createdAt"] as? Date
        {
            self.studyIDs = studyIDs
            self.reviewIDs = reviewIDs
            self.reviewedIDs = reviewedIDs
            self.createdAt = createdAt
        } else {
            throw AppError.Initializer.todayBookImpl
        }
    }
}
