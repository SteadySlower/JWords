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
    
    private func setTestStore() async -> TestStore<TodayList.State, TodayList.Action> {
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
            $0.scheduleClient.updateStudy = { _ in }
            $0.scheduleClient.updateReview = { _ in }
            $0.scheduleClient.clear = { }
        }

        
        await store.send(.onAppear) {
            $0.studySets = .mock
            $0.reviewSets = .mock
            $0.toStudyUnits = .mock
            $0.allStudyUnits = .mock
            $0.todayStatus.update(
                setCount: $0.studySets.count,
                allUnitCount: [StudyUnit].mock.count,
                toStudyUnitCount: $0.toStudyUnits.count
            )
        }
        
        return store
    }
    
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
            $0.toStudyUnits = .mock
            $0.allStudyUnits = .mock
            $0.todayStatus.update(
                setCount: $0.studySets.count,
                allUnitCount: $0.allStudyUnits.count,
                toStudyUnitCount: $0.toStudyUnits.count
            )
        }
    }
    
}
