//
//  KanjiSetClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay

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
        // TODO: Add Service Logic
        return .init(title: title, createdAt: Date(), closed: false)
    },
    fetch: {
        // TODO: Add Service Logic
        return []
    },
    addKanji: { kanji, set in
        // TODO: Add Service Logic
        return .init(index: 0)
    }
  )
}

extension KanjiSetClient: TestDependencyKey {
  static let previewValue = Self(
    insert: { title in .init(title: title, createdAt: Date(), closed: false) },
    fetch: { .mock },
    addKanji: { _, _ in .init(index: 0) }
  )
}



