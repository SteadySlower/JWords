//
//  WriteKanjisTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class WriteKanjisTest: XCTestCase {

    @MainActor
    func test_kanjis_kanjiSelected() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 1, to: 100))
        let store = TestStore(
            initialState: WriteKanjis.State(kanjis: kanjis),
            reducer: { WriteKanjis() }
        )
        let kanji = kanjis.randomElement()!
        await store.send(.kanjis(.kanjiSelected(kanji))) {
            $0.toWrite.setKanji(kanji)
        }
    }
    
}
