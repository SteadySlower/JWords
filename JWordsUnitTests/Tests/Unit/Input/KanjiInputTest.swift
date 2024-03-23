//
//  KanjiInputTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

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
    func test_view_convertToHurigana_when_textEmpty() async {
        let store = TestStore(
            initialState: KanjiInput.State(
                text: ""
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(\.view.convertToHurigana)
    }
    
    @MainActor
    func test_convertToHurigana() async {
        let text = Random.string
        let hurigana = Random.string
        
        let store = TestStore(
            initialState: KanjiInput.State(
                text: text
            ),
            reducer: { KanjiInput() },
            withDependencies: {
                $0.huriganaClient.convert = { _ in hurigana }
            }
        )
        
        await store.send(\.view.convertToHurigana) {
            $0.hurigana = EditHuriganaText.State(hurigana: hurigana)
            $0.isEditing = false
        }
        
        await store.receive(.huriganaUpdated(store.state.hurigana.hurigana))
    }
    
    @MainActor
    func test_editText() async {
        let text = Random.string
        let hurigana = HuriganaConverter.shared.convert(text)
        
        let store = TestStore(
            initialState: KanjiInput.State(
                hurigana: .init(hurigana: hurigana),
                isEditing: false
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(\.view.editText) {
            $0.isEditing = true
            $0.hurigana = EditHuriganaText.State(hurigana: "")
        }
        
        await store.receive(.huriganaUpdated(store.state.hurigana.hurigana))
    }
    
    @MainActor
    func test_editText_onHuriUpdated() async {
        let hurigana = HuriganaConverter.shared.convert(Random.string)
        
        let store = TestStore(
            initialState: KanjiInput.State(
                hurigana: .init(hurigana: hurigana)
            ),
            reducer: { KanjiInput() }
        )
        
        await store.send(\.editHuriText.onHuriUpdated)
        await store.receive(.huriganaUpdated(hurigana))
    }
    
}
