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
        
        let store = TestStore(initialState: TodayList.State()) {
            TodayList()
        } withDependencies: {
            $0.studySetClient.fetch = { _ in .mock }
            $0.studyUnitClient.fetchAll = { _ in .mock }
            $0.scheduleClient.study = { _ in .mock }
            $0.scheduleClient.review = { _ in .mock }
            $0.studyUnitClient.fetchAll = { _ in .mock }
            $0.utilClient.filterOnlyFailUnits = { _ in .mock }
            $0.scheduleClient.study = { _ in .mock }
            $0.scheduleClient.review = { _ in .mock }
        }

        
        await store.send(.onAppear) {
            $0.studySets = .mock
            $0.reviewSets = .mock
            $0.onlyFailUnits = .mock
            $0.todayStatus = .init(
                sets: $0.studySets.count,
                total: [StudyUnit].mock.count,
                wrong: $0.onlyFailUnits.count
            )
        }
    }
}