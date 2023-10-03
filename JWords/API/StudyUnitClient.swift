//
//  StudyUnitClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import ComposableArchitecture

struct StudyUnitClient {
    private static let cd = CoreDataService.shared
    var checkIfExist: (String) throws -> StudyUnit?
    var insert: (StudySet, StudyUnitInput) throws -> StudyUnit
    var edit: (StudyUnit, StudyUnitInput) throws -> StudyUnit
    var delete: (StudyUnit, StudySet) throws -> Void
    var studyState: (StudyUnit, StudyState) throws -> Void
    var move: ([StudyUnit], StudySet, StudySet) throws -> Void
    var fetch: (StudySet) throws -> [StudyUnit]
    
}

extension DependencyValues {
  var studyUnitClient: StudyUnitClient {
    get { self[StudyUnitClient.self] }
    set { self[StudyUnitClient.self] = newValue }
  }
}

extension StudyUnitClient: DependencyKey {
  static let liveValue = StudyUnitClient(
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
    }
  )
}

extension StudyUnitClient: TestDependencyKey {
  static let previewValue = Self(
    checkIfExist: { _ in nil },
    insert: { _, _ in .init(index: 0) },
    edit: { _, _ in .init(index: 0) },
    delete: { _, _ in },
    studyState: { _, _ in },
    move: { _, _, _ in  },
    fetch: { _ in .mock }
  )

  static let testValue = Self(
    checkIfExist: unimplemented("\(Self.self).checkIfExist"),
    insert: unimplemented("\(Self.self).insert"),
    edit: unimplemented("\(Self.self).edit"),
    delete: unimplemented("\(Self.self).delete"),
    studyState: unimplemented("\(Self.self).studyState"),
    move: unimplemented("\(Self.self).move"),
    fetch: unimplemented("\(Self.self).fetch")
  )
}


