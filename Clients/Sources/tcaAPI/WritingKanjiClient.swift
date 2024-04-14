//
//  WritingKanjiClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import Model
import CoreDataKit

public struct WritingKanjiClient {
    private static let cd = CoreDataService.shared
    public var fetch: (KanjiSet) throws -> [Kanji]
    public var studyState: (Kanji, StudyState) throws -> StudyState
    
    public static let liveValue = WritingKanjiClient(
    fetch: { set in
        try cd.fetchKanjis(kanjiSet: set)
    },
    studyState: { kanji, newState in
        try cd.updateStudyState(kanji: kanji, newState: newState)
        return newState
    }
  )
    
    public static let previewValue = Self(
    fetch: { _ in .mock },
    studyState: { _, state in state }
  )
    
    public static let testValue: WritingKanjiClient = Self(
    fetch: { _ in .mock },
    studyState: { _, state in state }
  )
}

