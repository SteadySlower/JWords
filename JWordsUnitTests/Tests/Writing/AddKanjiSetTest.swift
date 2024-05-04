//
//  AddKanjiSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords
import Model

final class AddKanjiSetTest: XCTestCase {
    
    @MainActor
    func test_updateTitle() async {
        let store = TestStore(
            initialState: AddKanjiSet.State(),
            reducer: { AddKanjiSet() }
        )
        XCTAssertEqual(store.state.title, "")
        let title = Random.string
        await store.send(.updateTitle(title)) {
            $0.title = title
        }
    }
    
    @MainActor
    func test_add() async {
        let kanjiSet: KanjiSet = .testMock
        let store = TestStore(
            initialState: AddKanjiSet.State(
                title: Random.string
            ),
            reducer: { AddKanjiSet() },
            withDependencies: {
                $0.kanjiSetClient.insert = { _ in kanjiSet }
            }
        )
        await store.send(.add)
        await store.receive(.added(kanjiSet))
    }
    
}
