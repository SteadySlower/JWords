//
//  WritingKanjiClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import ComposableArchitecture
import XCTestDynamicOverlay

struct WritingKanjiClient {
    var studyState: (Kanji, StudyState) throws -> StudyState
}

extension DependencyValues {
  var writingKanjiClient: WritingKanjiClient {
    get { self[WritingKanjiClient.self] }
    set { self[WritingKanjiClient.self] = newValue }
  }
}

extension WritingKanjiClient: DependencyKey {
  static let liveValue = WritingKanjiClient(
    studyState: { kanji, state in
        // TODO: add service logic
        return state
    }
  )
}

extension WritingKanjiClient: TestDependencyKey {
  static let previewValue = Self(
    studyState: { _, state in state }
  )
}

