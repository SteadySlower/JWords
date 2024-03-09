//
//  MainTabTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class MainTabTest: XCTestCase {
    func testChangeTab() async {
        let store = TestStore(
            initialState: MainTab.State(),
            reducer: { MainTab() }
        )

        
        XCTAssertEqual(store.state.selectedTab, .today)
        
        await store.send(.setTab(.home)) {
            $0.selectedTab = .home
        }
        
        await store.send(.setTab(.kanji)) {
            $0.selectedTab = .kanji
        }
        
        await store.send(.setTab(.kanjiWriting)) {
            $0.selectedTab = .kanjiWriting
        }
        
        await store.send(.setTab(.ocr)) {
            $0.selectedTab = .ocr
        }
        
        await store.send(.setTab(.today)) {
            $0.selectedTab = .today
        }
    }
}
