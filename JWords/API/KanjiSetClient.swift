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
    }
  )
}

extension KanjiSetClient: TestDependencyKey {
  static let previewValue = Self(
    insert: { title in .init(title: title, createdAt: Date(), closed: false) },
    fetch: { .mock }
  )
}



