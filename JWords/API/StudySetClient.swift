//
//  StudySetClient.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import ComposableArchitecture

struct StudySetClient {
    private static let cd = CoreDataService.shared
    var insertSet: (StudySetInput) throws -> Void
    var updateSet: (StudySet, StudySetInput) throws -> StudySet
    var closeSet: (StudySet) throws -> Void
}

extension DependencyValues {
  var studySetClient: StudySetClient {
    get { self[StudySetClient.self] }
    set { self[StudySetClient.self] = newValue }
  }
}

extension StudySetClient: DependencyKey {
  static let liveValue = StudySetClient(
    insertSet: { input in
        try cd.insertSet(title: input.title,
                         isAutoSchedule: input.isAutoSchedule,
                         preferredFrontType: input.preferredFrontType)
    },
    updateSet: { set, input in
        return try cd.updateSet(set,
                         title: input.title,
                         isAutoSchedule: input.isAutoSchedule,
                         preferredFrontType: input.preferredFrontType)
    },
    closeSet: { set in
        try cd.closeSet(set)
    }
  )
}

extension StudySetClient: TestDependencyKey {
  static let previewValue = Self(
    insertSet: { _ in },
    updateSet: { _, _ in return .init(index: 0) },
    closeSet: { _ in }
  )

  static let testValue = Self(
    insertSet: unimplemented("\(Self.self).inserSet"),
    updateSet: unimplemented("\(Self.self).updateSet"),
    closeSet: unimplemented("\(Self.self).closeSet")
  )
}


