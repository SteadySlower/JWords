//
//  WritingCoordinatorTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class WritingCoordinatorTest: XCTestCase {
    @MainActor
    func test_kanjiSetList_setSelected() async {
        let kanjis: [Kanji] = .testMock(count: Random.int(from: 0, to: 100))
        let store = TestStore(
            initialState: WritingCoordinator.State(),
            reducer: { WritingCoordinator() },
            withDependencies: {
                $0.writingKanjiClient.fetch = { _ in kanjis }
            }
        )
        await store.send(.kanjiSetList(.setSelected(.testMock))) {
            $0.path.append(.writing(.init(kanjis: kanjis)))
        }
    }
}
