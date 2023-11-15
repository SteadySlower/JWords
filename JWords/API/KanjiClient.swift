//
//  KanjiClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import ComposableArchitecture
import XCTestDynamicOverlay

struct KanjiClient {
    private static let cd = CoreDataService.shared
    var fetch: (Kanji?) throws -> [Kanji]
    var unitKanjis: (StudyUnit) throws -> [Kanji]
    var kanjiUnits: (Kanji) throws -> [StudyUnit]
    var edit: (Kanji, String) throws -> Kanji
    var searchWithKanjiText: (String) throws -> Kanji?
}

extension DependencyValues {
  var kanjiClient: KanjiClient {
    get { self[KanjiClient.self] }
    set { self[KanjiClient.self] = newValue }
  }
}

extension KanjiClient: DependencyKey {
  static let liveValue = KanjiClient(
    fetch: { kanji in
        try cd.fetchAllKanjis(after: kanji)
    },
    unitKanjis: { unit in
        try cd.fetchKanjis(usedIn: unit)
    },
    kanjiUnits: { kanji in
        try cd.fetchSampleUnit(ofKanji: kanji)
    },
    edit: { kanji, meaningText in
        try cd.editKanji(kanji: kanji, meaningText: meaningText)
    },
    searchWithKanjiText: { kanjiText in
        try cd.fetchKanjis(kanjiText: kanjiText).first
    }
  )
}

extension KanjiClient: TestDependencyKey {
  static let previewValue = Self(
    fetch: { _ in .mock },
    unitKanjis: { _ in .mock },
    kanjiUnits: { _ in .mock },
    edit: { _, _ in .init(index: 0) }
  )
}



