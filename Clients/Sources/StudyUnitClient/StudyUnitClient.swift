//
//  StudyUnitClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Model
import CoreDataKit
import ComposableArchitecture
import XCTestDynamicOverlay

public struct StudyUnitClient {
    private static let cd = CoreDataService.shared
    public var checkIfExist: (String) throws -> StudyUnit?
    public var insert: (StudySet, StudyUnitInput) throws -> StudyUnit
    public var insertExisting: (StudySet, StudyUnit) throws -> StudyUnit
    public var edit: (StudyUnit, StudyUnitInput) throws -> StudyUnit
    public var delete: (StudyUnit, StudySet) throws -> Void
    public var studyState: (StudyUnit, StudyState) throws -> StudyState
    public var move: ([StudyUnit], StudySet, StudySet) throws -> Void
    public var fetch: (StudySet) throws -> [StudyUnit]
    public var fetchAll: ([StudySet]) throws -> [StudyUnit]
}

extension DependencyValues {
    public var studyUnitClient: StudyUnitClient {
        get { self[StudyUnitClient.self] }
        set { self[StudyUnitClient.self] = newValue }
    }
}

extension StudyUnitClient: DependencyKey {
    public static let liveValue = StudyUnitClient(
        checkIfExist: { kanjiText in
            return try cd.checkIfExist(kanjiText)
        },
        insert: { set, input in
            return try cd.insertUnit(
                in: set,
                type: input.type,
                kanjiText: input.kanjiText,
                meaningText: input.meaningText
            )
        },
        insertExisting: { set, unit in
            return try cd.addExistingUnit(
                set: set,
                unit: unit
            )
        },
        edit: { unit, input in
            return try cd.editUnit(
                of: unit,
                type: input.type,
                kanjiText: input.kanjiText,
                meaningText: input.meaningText
            )
        },
        delete: { unit, set in
            try cd.deleteUnit(
                unit: unit,
                from: set
            )
        },
        studyState: { unit, state in
            try cd.updateStudyState(
                unit: unit,
                newState: state
            )
            return state
        },
        move: { units, from, to in
            try cd.moveUnits(
                units: units,
                from: from,
                to: to
            )
        },
        fetch: { set in
            try cd.fetchUnits(of: set)
        },
        fetchAll: { sets in
            try sets
            .map { try cd.fetchUnits(of: $0) }
            .reduce([], +)
        }
    )
}

extension StudyUnitClient: TestDependencyKey {
    public static let previewValue = Self(
        checkIfExist: { _ in nil },
        insert: { _, _ in .init(index: 0) },
        insertExisting: { _, _ in .init(index: 0) },
        edit: { _, _ in .init(index: 0) },
        delete: { _, _ in },
        studyState: { _, state in state },
        move: { _, _, _ in  },
        fetch: { _ in .mock },
        fetchAll: { _ in .mock }
    )
    public static let testValue: StudyUnitClient = Self(
        checkIfExist: { _ in nil },
        insert: { _, _ in .init(index: 0) },
        insertExisting: { _, _ in .init(index: 0) },
        edit: { _, _ in .init(index: 0) },
        delete: { _, _ in },
        studyState: { _, state in state },
        move: { _, _, _ in  },
        fetch: { _ in .mock },
        fetchAll: { _ in .mock }
    )
}
