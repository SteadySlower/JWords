//
//  ScheduleClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/10/03.
//

import ComposableArchitecture
import Foundation

struct ScheduleClient {
    private static let kv = KeyValueStoreService.shared
    var fetch: () -> TodaySchedule
    var autoSet: ([StudySet]) -> Void
    var update: (TodaySchedule) -> Void
    var reviewed: (StudySet) -> Void
}

extension DependencyValues {
  var scheduleClient: ScheduleClient {
    get { self[ScheduleClient.self] }
    set { self[ScheduleClient.self] = newValue }
  }
}

extension ScheduleClient: DependencyKey {
  static let liveValue = ScheduleClient(
    fetch: {
        TodaySchedule(studyIDs: kv.arrayOfString(for: .studySets),
                      reviewIDs: kv.arrayOfString(for: .reviewSets),
                      reviewedIDs: kv.arrayOfString(for: .reviewedSets),
                      createdAt: kv.date(for: .createdAt))
    },
    autoSet: { sets in
        let studySets = sets.filter { $0.schedule == .study }.map { $0.id }
        let reviewSets = sets.filter { $0.schedule == .review }.map { $0.id }
        kv.setArrayOfString(key: .studySets, value: studySets)
        kv.setArrayOfString(key: .reviewSets, value: reviewSets)
        kv.setArrayOfString(key: .reviewedSets, value: [])
        kv.setDate(key: .createdAt, value: Date())
    },
    update: { schedule in
        kv.setArrayOfString(key: .studySets, value: schedule.studyIDs)
        kv.setArrayOfString(key: .reviewSets, value: schedule.reviewIDs)
        kv.setArrayOfString(key: .reviewedSets, value: schedule.reviewedIDs)
        kv.setDate(key: .createdAt, value: Date())
    },
    reviewed: { set in
        var reviewedIDs = kv.arrayOfString(for: .reviewedSets)
        reviewedIDs.append(set.id)
        kv.setArrayOfString(key: .reviewedSets, value: reviewedIDs)
        kv.setDate(key: .createdAt, value: Date())
    }
  )
}

extension ScheduleClient: TestDependencyKey {
  static let previewValue = Self(
    fetch: { .empty },
    autoSet: { _ in },
    update: { _ in },
    reviewed: { _ in }
  )

  static let testValue = Self(
    fetch: unimplemented("\(Self.self).fetch"),
    autoSet: unimplemented("\(Self.self).autoSet"),
    update: unimplemented("\(Self.self).update"),
    reviewed: unimplemented("\(Self.self).reviewed")
  )
}
