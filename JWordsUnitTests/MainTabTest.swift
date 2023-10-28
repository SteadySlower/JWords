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
        
        await store.send(.tabChanged(.home)) {
            $0.selectedTab = .home
        }
        
        await store.send(.tabChanged(.kanji)) {
            $0.selectedTab = .kanji
        }
        
        await store.send(.tabChanged(.ocr)) {
            $0.selectedTab = .ocr
        }
    }
}


/* TODO: WILL_MAKE_TEST_LIST
 - PieChartReducer
 - TodayStatus
 - SelectStudySet
 - EditableHuriUnit
*/
