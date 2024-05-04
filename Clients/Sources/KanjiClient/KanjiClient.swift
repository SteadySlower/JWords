//
//  KanjiClient.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Model
import CoreDataKit
import ComposableArchitecture
import XCTestDynamicOverlay

public struct KanjiClient {
    private static let cd = CoreDataService.shared
    public var fetch: (Kanji?, Int) throws -> [Kanji]
    public var unitKanjis: (StudyUnit) throws -> [Kanji]
    public var kanjiUnits: (Kanji) throws -> [StudyUnit]
    public var edit: (Kanji, StudyKanjiInput) throws -> Kanji
    public var search: (String) throws -> [Kanji]
}

extension DependencyValues {
    public var kanjiClient: KanjiClient {
        get { self[KanjiClient.self] }
        set { self[KanjiClient.self] = newValue }
    }
}

extension KanjiClient: DependencyKey {
    public static let liveValue = KanjiClient(
        fetch: { kanji, pageSize in
            try cd.fetchAllKanjis(after: kanji, pageSize: pageSize)
        },
        unitKanjis: { unit in
            try cd.fetchKanjis(usedIn: unit)
        },
        kanjiUnits: { kanji in
            try cd.fetchSampleUnit(ofKanji: kanji)
        },
        edit: { kanji, input in
            try cd.editKanji(kanji: kanji, input: input)
        },
        search: { query in
            try cd.fetchKanjis(query: query)
        }
    )
}

extension KanjiClient: TestDependencyKey {
    public static let previewValue = Self(
        fetch: { _, _ in .mock },
        unitKanjis: { _ in .mock },
        kanjiUnits: { _ in .mock },
        edit: { _, _ in .init(index: 0) },
        search: { _ in .mock }
    )
    
    public static let testValue: KanjiClient = Self(
        fetch: { _, _ in .mock },
        unitKanjis: { _ in .mock },
        kanjiUnits: { _ in .mock },
        edit: { _, _ in .init(index: 0) },
        search: { _ in .mock }
    )
}
