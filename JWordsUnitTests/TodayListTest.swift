//
//  TodayListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/05.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class TodayListTest: XCTestCase {
    func testOnAppear() async {
        let store = TestStore(
            initialState: TodayList.State(),
            reducer: TodayList()
        )
    }
}






























