//
//  ScheduleClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/10/03.
//

import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct ScheduleClient {
    private static let kv = KeyValueStoreService.shared
    var study: ([StudySet]) -> [StudySet]
    var review: ([StudySet]) -> [StudySet]
    var updateStudy: ([StudySet]) -> [StudySet]
    var updateReview: ([StudySet]) -> [StudySet]
    var clear: () -> Void
    var autoSet: ([StudySet]) -> Void
    var reviewed: (StudySet) -> Void
    var isReview: (StudySet) -> Bool
}

extension ScheduleClient: DependencyKey {
  static let liveValue = ScheduleClient(
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
  static let previewValue = Self(
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
