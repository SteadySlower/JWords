//
//  AddWritingKanjiTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class AddWritingKanjiTest: XCTestCase {
    
    @MainActor
    func test_updateID() async {
        let store = TestStore(
            initialState: AddWritingKanji.State(
                kanji: .testMock,
                kanjiSets: .testMock
            ),
            reducer: { AddWritingKanji() }
        )
        XCTAssertEqual(store.state.selectedID, nil)
        let id = Random.string
        await store.send(.setID(id)) {
            $0.selectedID = id
        }
    }
    
    @MainActor
    func test_add_when_selectedID_nil() async {
        let store = TestStore(
            initialState: AddWritingKanji.State(
                kanji: .testMock,
                kanjiSets: .testMock,
                selectedID: nil
            ),
            reducer: { AddWritingKanji() }
        )
        await store.send(.add)
    }
    
    @MainActor
    func test_add_when_selectedID_not_nil() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let kanjiSets: [KanjiSet] = .testMock
        let store = TestStore(
            initialState: AddWritingKanji.State(
                kanji: .testMock,
                kanjiSets: kanjiSets,
                selectedID: kanjiSets.randomElement()!.id
            ),
            reducer: { AddWritingKanji() },
            withDependencies: {
                $0.kanjiSetClient.addKanji = { _, _ in .testMock }
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        await store.send(.add)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_add_when_selectedID_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: AddWritingKanji.State(
                kanji: .testMock,
                kanjiSets: .testMock
            ),
            reducer: { AddWritingKanji() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
}
