//
//  KanjiSetClient.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import ComposableArchitecture
import XCTestDynamicOverlay

struct KanjiSetClient {
    private static let cd = CoreDataService.shared
    var insert: (String) throws -> KanjiSet
    var fetch: () throws -> [KanjiSet]
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
        return .init(index: 0)
    },
    fetch: {
        return []
    }
  )
}

extension KanjiSetClient: TestDependencyKey {
  static let previewValue = Self(
    insert: { _ in .init(index: 0) },
    fetch: { .mock }
  )
}



