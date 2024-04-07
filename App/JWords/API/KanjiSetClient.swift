//
//  KanjiSetClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Model
import CoreDataKit

struct KanjiSetClient {
    private static let cd = CoreDataService.shared
    var insert: (String) throws -> KanjiSet
    var fetch: () throws -> [KanjiSet]
    var addKanji: (Kanji, KanjiSet) throws -> KanjiSet
}

extension DependencyValues {
  var kanjiSetClient: KanjiSetClient {
    get { self[KanjiSetClient.self] }
    set { self[KanjiSetClient.self] = newValue }
  }
}

extension KanjiSetClient: DependencyKey {
  static let liveValue = KanjiSetClient(
    insert: { title in
        try cd.insertKanjiSet(title: title, isAutoSchedule: true)
    },
    fetch: {
        try cd.fetchKanjiSets()
    },
    addKanji: { kanji, set in
        try cd.insertKanji(kanji, in: set)
    }
  )
}

extension KanjiSetClient: TestDependencyKey {
  static let previewValue = Self(
    insert: { title in .init(title: title, createdAt: Date(), closed: false) },
    fetch: { .mock },
    addKanji: { _, set in set }
  )
}



