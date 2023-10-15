//
//  KanjiInputTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class KanjiInputTest: XCTestCase {
    
    func testUpdateText() async {
        let store = TestStore(
            initialState: KanjiInput.State(),
            reducer: { KanjiInput() }
        )
        
        let text = Random.string
        
        await store.send(.updateText(text)) {
            $0.text = text
        }
    }
    
    func testUpdateTextHasTab() async {
        let store = TestStore(
            initialState: KanjiInput.State(),
            reducer: { KanjiInput() }
        )
        
        let textWithTab = [
            "\t",
            "\t" + Random.string,
            Random.string + "\t",
            Random.string + "\t" + Random.string,
        ].randomElement()!
        
        await store.send(.updateText(textWithTab))
        await store.receive(.onTab)
    }
    
    func test_converHurigana_whenTextEmpty() async {
        let store = TestStore(
            initialState: KanjiInput.State(
                text: ""
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(.convertToHurigana)
    }
    
    func test_convertHurigana() async {
        let text = Random.string
        let hurigana = HuriganaConverter.shared.convert(text)
        
        let store = TestStore(
            initialState: KanjiInput.State(
                text: text
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(.convertToHurigana) {
            $0.hurigana = EditHuriganaText.State(hurigana: hurigana)
            $0.isEditing = false
        }
        
        await store.receive(.huriganaUpdated(hurigana))
    }
    
}
