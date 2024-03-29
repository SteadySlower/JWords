//
//  SearchKanjiTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 1/6/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords


final class SearchKanjiTest: XCTestCase {
    
    @MainActor
    func test_updateQuery() async {
        let searched: [Kanji] = .testMock(count: Random.int(from: 0, to: 100))
        
        let store = TestStore(
            initialState: SearchKanji.State(),
            reducer: { SearchKanji() },
            withDependencies: {
                $0.kanjiClient.search = { _ in searched }
            }
        )
        
        let query = Random.string

        await store.send(.updateQuery(query)) {
            $0.query = query
        }
        await store.receive(.kanjiSearched(searched))
    }
    
    @MainActor
    func test_updateQuery_with_empty_query() async {
        let store = TestStore(
            initialState: SearchKanji.State(query: Random.string),
            reducer: { SearchKanji() }
        )

        await store.send(.updateQuery("")) {
            $0.query = ""
        }
        await store.receive(.queryRemoved)
    }
}

