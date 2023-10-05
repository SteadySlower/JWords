//
//  iOSAppTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class iOSAppTest: XCTestCase {
    func testChangeTab() async {
        let store = TestStore(
            initialState: iOSApp.State(),
            reducer: iOSApp()
        )
        
        XCTAssertEqual(store.state.selectedTab, .today)
        
        await store.send(.tabChanged(.home)) {
            $0.selectedTab = .home
            $0.homeList = HomeList.State()
            $0.todayList = nil
        }
        
        await store.send(.tabChanged(.kanji)) {
            $0.selectedTab = .kanji
            $0.kanjiList = KanjiList.State()
            $0.homeList = nil
        }
        
        await store.send(.tabChanged(.ocr)) {
            $0.selectedTab = .ocr
            $0.ocr = AddUnitWithOCR.State()
            $0.kanjiList = nil
        }
    }
}





























