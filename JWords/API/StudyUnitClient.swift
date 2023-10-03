//
//  StudyUnitClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import ComposableArchitecture

struct StudyUnitClient {
    private static let cd = CoreDataService.shared
    var insertUnit: (StudySet, StudyUnitInput) throws -> StudyUnit
    var editUnit: (StudyUnit, StudyUnitInput) throws -> StudyUnit
    var addExistingUnit: (StudyUnit, StudySet, String) throws -> StudyUnit
    var removeUnit: (StudyUnit, StudySet) throws -> Void
    var updateStudyState: (StudyUnit, StudyState) throws -> Void
}

extension DependencyValues {
  var studyUnitClient: StudyUnitClient {
    get { self[StudyUnitClient.self] }
    set { self[StudyUnitClient.self] = newValue }
  }
}

extension StudyUnitClient: DependencyKey {
  static let liveValue = StudyUnitClient(
    insertUnit: { set, input in
        return try cd.insertUnit(
            in: set,
            type: input.type,
            kanjiText: input.kanjiText,
            meaningText: input.meaningText
        )
    },
    editUnit: { unit, input in
        return try cd.editUnit(
            of: unit,
            type: input.type,
            kanjiText: input.kanjiText,
            meaningText: input.meaningText
        )
    },
    addExistingUnit: { unit, set, meaningText in
        return try cd.addExistingUnit(
            unit: unit,
            meaningText: meaningText,
            in: set
        )
    },
    removeUnit: { unit, set in
        try cd.deleteUnit(
            unit: unit,
            from: set
        )
    },
    updateStudyState: { unit, state in
        try cd.updateStudyState(
            unit: unit,
            newState: state
        )
    }
  )
}

extension StudyUnitClient: TestDependencyKey {
  static let previewValue = Self(
    insertUnit: { _, _ in .init(index: 0) },
    editUnit: { _, _ in .init(index: 0) },
    addExistingUnit: { _, _, _ in .init(index: 0) },
    removeUnit: { _, _ in },
    updateStudyState: { _, _ in }
  )

  static let testValue = Self(
    insertUnit: unimplemented("\(Self.self).insertUnit"),
    editUnit: unimplemented("\(Self.self).editUnit"),
    addExistingUnit: unimplemented("\(Self.self).addExistingUnit"),
    removeUnit: unimplemented("\(Self.self).removeUnit"),
    updateStudyState: unimplemented("\(Self.self).updateStudyState")
  )
}


