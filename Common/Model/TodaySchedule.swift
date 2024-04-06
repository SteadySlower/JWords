//
//  TodaySchedule.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/10/25.
//

import Foundation

public struct TodaySchedule: Equatable {
    let studyIDs: [String]
    let reviewIDs: [String]
    let reviewedIDs: [String]
    let createdAt: Date
    
    public init(studyIDs: [String], reviewIDs: [String], reviewedIDs: [String], createdAt: Date) {
        self.studyIDs = studyIDs
        self.reviewIDs = reviewIDs
        self.reviewedIDs = reviewedIDs
        self.createdAt = createdAt
    }
    
    public static let empty: Self = .init(studyIDs: [], reviewIDs: [], reviewedIDs: [], createdAt: .now)

}

public struct TodaySets: Equatable {
    
    public let study: [StudySet]
    public let review: [StudySet]
    public let reviewed: [StudySet]
    
    public init(sets: [StudySet], schedule: TodaySchedule) {
        self.study = sets.filter { schedule.studyIDs.contains($0.id) }
        self.review = sets.filter {
            schedule.reviewIDs.contains($0.id) && !schedule.reviewedIDs.contains($0.id)
        }
        self.reviewed = sets.filter {
            schedule.reviewIDs.contains($0.id) && schedule.reviewedIDs.contains($0.id)
        }
    }
    
}
