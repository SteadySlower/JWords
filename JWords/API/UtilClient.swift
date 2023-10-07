//
//  UtilClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/06.
//

import ComposableArchitecture
import XCTestDynamicOverlay

struct UtilClient {
    var filterOnlyFailUnits: ([StudyUnit]) -> [StudyUnit]
    var shuffleUnits: ([StudyUnit]) -> [StudyUnit]
}

extension DependencyValues {
  var utilClient: UtilClient {
    get { self[UtilClient.self] }
    set { self[UtilClient.self] = newValue }
  }
}

extension UtilClient: DependencyKey {
  static let liveValue = UtilClient(
    filterOnlyFailUnits: { units in
        units
            .filter { $0.studyState != .success }
            .removeOverlapping()
            .sorted(by: { $0.createdAt < $1.createdAt })
    },
    shuffleUnits: { units in
        units.shuffled()
    }
  )
}

extension UtilClient: TestDependencyKey {
  static let previewValue = Self(
    filterOnlyFailUnits: { _ in .mock },
    shuffleUnits: { _ in .mock }
  )

  static let testValue = Self(
    filterOnlyFailUnits: unimplemented("\(Self.self).filterOnlyFailUnits"),
    shuffleUnits: unimplemented("\(Self.self).shuffleUnits")
  )
}

