//
//  EditKanjiTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class EditKanjiTest: XCTestCase {
    
    @MainActor
    func test_edit() async {
        let kanji: Kanji = .testMock
        let store = TestStore(
            initialState: EditKanji.State(.testMock),
            reducer: { EditKanji() },
            withDependencies: {
                $0.kanjiClient.edit = { _, _ in kanji }
            }
        )
        await store.send(.edit)
        await store.receive(.edited(kanji))
    }
    
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: EditKanji.State(.testMock),
            reducer: { EditKanji() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
}
