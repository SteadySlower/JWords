//
//  WritingKanjiClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Model

struct WritingKanjiClient {
    private static let cd = CoreDataService.shared
    var fetch: (KanjiSet) throws -> [Kanji]
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
    fetch: { set in
        try cd.fetchKanjis(kanjiSet: set)
    },
    studyState: { kanji, newState in
        try cd.updateStudyState(kanji: kanji, newState: newState)
        return newState
    }
  )
}

extension WritingKanjiClient: TestDependencyKey {
  static let previewValue = Self(
    fetch: { _ in .mock },
    studyState: { _, state in state }
  )
}

