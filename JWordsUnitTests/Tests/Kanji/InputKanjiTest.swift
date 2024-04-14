//
//  InputKanjiTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class InputKanjiTest: XCTestCase {
    
    @MainActor
    func test_setKanji_isKanjiEditable_true() async {
        let store = TestStore(
            initialState: InputKanji.State(isKanjiEditable: true),
            reducer: { InputKanji() }
        )
        XCTAssertEqual(store.state.kanji, "")
        let kanjiString = Random.string
        await store.send(.setKanji(kanjiString)) {
            $0.kanji = kanjiString
        }
    }
    
    @MainActor
    func test_setKanji_isKanjiEditable_false() async {
        let store = TestStore(
            initialState: InputKanji.State(isKanjiEditable: false),
            reducer: { InputKanji() }
        )
        XCTAssertEqual(store.state.kanji, "")
        await store.send(.setKanji(Random.string))
    }
    
    @MainActor
    func test_setMeaning() async {
        let store = TestStore(
            initialState: InputKanji.State(),
            reducer: { InputKanji() }
        )
        XCTAssertEqual(store.state.meaning, "")
        let meaningString = Random.string
        await store.send(.setMeaning(meaningString)) {
            $0.meaning = meaningString
        }
    }
    
    @MainActor
    func test_setOndoku() async {
        let store = TestStore(
            initialState: InputKanji.State(),
            reducer: { InputKanji() }
        )
        XCTAssertEqual(store.state.ondoku, "")
        let ondokuString = Random.string
        await store.send(.setOndoku(ondokuString)) {
            $0.ondoku = ondokuString
        }
    }
    
    @MainActor
    func test_setKundoku() async {
        let store = TestStore(
            initialState: InputKanji.State(),
            reducer: { InputKanji() }
        )
        XCTAssertEqual(store.state.kundoku, "")
        let kundokuString = Random.string
        await store.send(.setKundoku(kundokuString)) {
            $0.kundoku = kundokuString
        }
    }
}
