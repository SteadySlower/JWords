//
//  WritingKanjiClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import ComposableArchitecture
import XCTestDynamicOverlay
import Model
import CoreDataKit

public struct WritingKanjiClient {
    private static let cd = CoreDataService.shared
    public var fetch: (KanjiSet) throws -> [Kanji]
    public var studyState: (Kanji, StudyState) throws -> StudyState
}

extension DependencyValues {
    public var writingKanjiClient: WritingKanjiClient {
    get { self[WritingKanjiClient.self] }
    set { self[WritingKanjiClient.self] = newValue }
  }
}

extension WritingKanjiClient: DependencyKey {
    public static let liveValue = WritingKanjiClient(
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
    public static let previewValue = Self(
    fetch: { _ in .mock },
    studyState: { _, state in state }
  )
    
    public static let testValue: WritingKanjiClient = Self(
    fetch: { _ in .mock },
    studyState: { _, state in state }
  )
}

