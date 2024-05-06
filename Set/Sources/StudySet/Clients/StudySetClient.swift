//
//  StudySetClient.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import Model
import CoreDataKit
import ComposableArchitecture
import XCTestDynamicOverlay

struct StudySetClient {
    private static let cd = CoreDataService.shared
    var insert: (StudySetInput) throws -> StudySet
    var update: (StudySet, StudySetInput) throws -> StudySet
    var close: (StudySet) throws -> Void
    var fetch: (Bool) throws -> [StudySet]
    var countUnits: (StudySet) throws -> Int
}

extension DependencyValues {
    var studySetClient: StudySetClient {
        get { self[StudySetClient.self] }
        set { self[StudySetClient.self] = newValue }
    }
}

extension StudySetClient: DependencyKey {
    static let liveValue = StudySetClient(
        insert: { input in
            return try cd.insertSet(
                title: input.title,
                isAutoSchedule: input.isAutoSchedule,
                preferredFrontType: input.preferredFrontType
            )
        },
        update: { set, input in
            return try cd.updateSet(
                set,
                title: input.title,
                isAutoSchedule: input.isAutoSchedule,
                preferredFrontType: input.preferredFrontType
            )
        },
        close: { set in
            try cd.closeSet(set)
        },
        fetch: { includeClosed in
            return try cd.fetchSets(includeClosed: includeClosed)
        },
        countUnits: { set in
            return try cd.countUnits(in: set)
        }
    )
}

extension StudySetClient: TestDependencyKey {
    static let previewValue = Self(
        insert: { input in .init(title: input.title) },
        update: { _, _ in return .init(index: 0) },
        close: { _ in },
        fetch: { _ in .mock },
        countUnits: { _ in Int.random(in: 0...100) }
    )
    static let testValue: StudySetClient = Self(
        insert: { input in .init(title: input.title) },
        update: { _, _ in return .init(index: 0) },
        close: { _ in },
        fetch: { _ in .mock },
        countUnits: { _ in Int.random(in: 0...100) }
    )
}
