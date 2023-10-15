//
//  KanjiListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class KanjiListTest: XCTestCase {
    
    func test_onAppear() async {
        let fetchKanjiCount = KanjiList.NUMBER_OF_KANJI_IN_A_PAGE
        let fetched: [Kanji] = .testMock(count: fetchKanjiCount)
        
        let store = TestStore(
            initialState: KanjiList.State(),
            reducer: { KanjiList() },
            withDependencies: {
                $0.kanjiClient.fetch = { _ in fetched }
            }
        )
        
        await store.send(.onAppear)
        
        await store.receive(.fetchKanjis) {
            $0.kanjis.append(contentsOf: fetched)
        }
    }
    
}
