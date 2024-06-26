//
//  ScheduleClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/10/03.
//

import Model
import UserDefaultKit
import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

public struct ScheduleClient {
    private static let kv = KeyValueStoreService.shared
    public var study: ([StudySet]) -> [StudySet]
    public var review: ([StudySet]) -> [StudySet]
    public var updateStudy: ([StudySet]) -> [StudySet]
    public var updateReview: ([StudySet]) -> [StudySet]
    public var clear: () -> Void
    public var autoSet: ([StudySet]) -> Void
    public var reviewed: (StudySet) -> Void
    public var isReview: (StudySet) -> Bool
}

extension DependencyValues {
    public var scheduleClient: ScheduleClient {
        get { self[ScheduleClient.self] }
        set { self[ScheduleClient.self] = newValue }
    }
}

extension ScheduleClient: DependencyKey {
    public static let liveValue = ScheduleClient(
        study: { sets in
            let studyIDs = kv.arrayOfString(for: .studySets)
            return sets.filter { studyIDs.contains($0.id) }
        },
        review: { sets in
            let reviewIDs = kv.arrayOfString(for: .reviewSets)
            return sets.filter { reviewIDs.contains($0.id) }
        },
        updateStudy: { sets in
            kv.setArrayOfString(key: .studySets, value: sets.map { $0.id })
            return sets.sorted(by: { $0.createdAt > $1.createdAt })
        },
        updateReview: { sets in
            kv.setArrayOfString(key: .reviewSets, value: sets.map { $0.id })
            return sets.sorted(by: { $0.createdAt > $1.createdAt })
        },
        clear: {
            kv.setArrayOfString(key: .studySets, value: [])
            kv.setArrayOfString(key: .reviewSets, value: [])
            kv.setDate(key: .createdAt, value: Date())
        },
        autoSet: { sets in
            let studySets = sets.filter { $0.schedule == .study }.map { $0.id }
            let reviewSets = sets.filter { $0.schedule == .review }.map { $0.id }
            kv.setArrayOfString(key: .studySets, value: studySets)
            kv.setArrayOfString(key: .reviewSets, value: reviewSets)
            kv.setDate(key: .createdAt, value: Date())
        },
        reviewed: { set in
            var newReviewIDs = kv.arrayOfString(for: .reviewSets).filter { $0 != set.id }
            kv.setArrayOfString(key: .reviewSets, value: newReviewIDs)
        },
        isReview: { set in
            let reviewIDs = kv.arrayOfString(for: .reviewSets)
            return reviewIDs.contains(set.id)
        }
    )
}

extension ScheduleClient: TestDependencyKey {
    public static let previewValue = Self(
        study: { _ in .mock },
        review: { _ in .mock },
        updateStudy: { _ in .mock },
        updateReview: { _ in .mock },
        clear: { },
        autoSet: { _ in },
        reviewed: { _ in },
        isReview: { _ in false }
    )

    public static let testValue: ScheduleClient = Self(
        study: { _ in .mock },
        review: { _ in .mock },
        updateStudy: { _ in .mock },
        updateReview: { _ in .mock },
        clear: { },
        autoSet: { _ in },
        reviewed: { _ in },
        isReview: { _ in false }
    )
}
