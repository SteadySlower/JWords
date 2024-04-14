//
//  KanjiInputTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords
import HuriConverter

final class KanjiInputTest: XCTestCase {

    @MainActor
    func test_setText() async {
        let store = TestStore(
            initialState: KanjiInput.State(),
            reducer: { KanjiInput() }
        )
        
        let text = Random.string
        
        await store.send(.setText(text)) {
            $0.text = text
        }
    }
    
    @MainActor
    func test_setText_hasTab() async {
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
        
        await store.send(.setText(textWithTab))
        await store.receive(.onTab)
    }
    
    @MainActor
    func test_view_updateHuri() async {
        let huris: [Huri] = .testMock
        let huri = huris.randomElement()!
        let updatedHuri = Huri(id: huri.id, kanji: huri.kanji, gana: Random.string)
        let store = TestStore(
            initialState: KanjiInput.State(
                huris: huris
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(\.view.updateHuri, updatedHuri) {
            $0.huris.update(updatedHuri)
        }
    }
    
    @MainActor
    func test_view_convertToHurigana_when_text_empty() async {
        let store = TestStore(
            initialState: KanjiInput.State(
                text: ""
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(\.view.convertToHurigana)
    }
    
    @MainActor
    func test_view_convertToHurigana_when_text_not_empty() async {
        let text = Random.string
        let hurigana = Random.string
        let huris: [Huri] = .testMock
        
        let store = TestStore(
            initialState: KanjiInput.State(
                text: text
            ),
            reducer: { KanjiInput() },
            withDependencies: {
                $0.huriganaClient.convert = { _ in hurigana }
                $0.huriganaClient.convertToHuris = { _ in huris }
            }
        )
        
        await store.send(\.view.convertToHurigana) {
            $0.huris = huris
            $0.isEditing = false
        }
        
        await store.receive(.huriganaUpdated(hurigana))
    }
    
    @MainActor
    func test_view_editText() async {
        let store = TestStore(
            initialState: KanjiInput.State(
                text: Random.string,
                huris: .testMock,
                isEditing: false
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(\.view.editText) {
            $0.isEditing = true
            $0.huris = []
        }
        
        await store.receive(.huriganaCleared)
    }
    
}
