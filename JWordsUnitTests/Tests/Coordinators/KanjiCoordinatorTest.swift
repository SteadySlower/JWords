//
//  KanjiCoordinatorTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class KanjiCoordinatorTest: XCTestCase {
    @MainActor
    func test_kanjiList_showSamples() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let units: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: KanjiCoordinator.State(
                kanjiList: .init(kanjis: IdentifiedArray(uniqueElements: kanjis.map { DisplayKanji.State(kanji: $0) }))
            ),
            reducer: { KanjiCoordinator() },
            withDependencies: {
                $0.kanjiClient.kanjiUnits = { _ in units }
            }
        )
        let kanji = kanjis.randomElement()!
        await store.send(.kanjiList(.kanji(.element(id: kanji.id, action: .showSamples(kanji))))) {
            $0.path.append(.samples(StudyKanjiSamples.State(kanji: kanji, units: units)))
        }
    }
}
