//
//  WritingKanjiListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class WritingKanjiListTest: XCTestCase {
    
    @MainActor
    func test_kanjiSelected() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let store = TestStore(
            initialState: WritingKanjiList.State(kanjis: IdentifiedArray(uniqueElements: kanjis.map { DisplayWritingKanji.State(kanji: $0) })),
            reducer: { WritingKanjiList() }
        )
        let kanji = kanjis.randomElement()!
        await store.send(\.kanji[id: kanji.id].select)
        await store.receive(.kanjiSelected(kanji))
    }
    
}
