//
//  TodayListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/05.
//

import ComposableArchitecture
import XCTest

@testable import JWords

private let fetchSets: [StudySet] = .testMock
private let fetchAllUnits: [StudyUnit] = .testMock
private let scheduleStudySets: [StudySet] = .notClosedTestMock
private let scheduleReviewSets: [StudySet] = .notClosedTestMock
private let filterOnlyFailUnits: [StudyUnit] = .testMock

@MainActor
final class TodayListTest: XCTestCase {
    
    private func setTestStore() async -> TestStore<TodayList.State, TodayList.Action> {
        let store = TestStore(initialState: TodayList.State()) {
            TodayList()
        } withDependencies: {
            $0.studySetClient.fetch = { _ in fetchSets }
            $0.studyUnitClient.fetchAll = { _ in fetchAllUnits }
            $0.scheduleClient.study = { _ in scheduleStudySets }
            $0.scheduleClient.review = { _ in scheduleReviewSets }
            $0.utilClient.filterOnlyFailUnits = { _ in filterOnlyFailUnits }
            $0.scheduleClient.updateStudy = { _ in }
            $0.scheduleClient.updateReview = { _ in }
            $0.scheduleClient.clear = { }
        }

        
        await store.send(.onAppear) {
            $0.todayStatus.update(
                studySets: scheduleStudySets,
                allUnits: fetchAllUnits,
                toStudyUnits: filterOnlyFailUnits
            )
            $0.reviewSets = scheduleReviewSets
        }
        
        return store
    }
    
    func testOnAppear() async {
        let store = TestStore(initialState: TodayList.State()) {
            TodayList()
        } withDependencies: {
            $0.studySetClient.fetch = { _ in fetchSets }
            $0.studyUnitClient.fetchAll = { _ in fetchAllUnits }
            $0.scheduleClient.study = { _ in scheduleStudySets }
            $0.scheduleClient.review = { _ in scheduleReviewSets }
            $0.utilClient.filterOnlyFailUnits = { _ in filterOnlyFailUnits }
            $0.scheduleClient.updateStudy = { _ in }
            $0.scheduleClient.updateReview = { _ in }
            $0.scheduleClient.clear = { }
        }

        
        await store.send(.onAppear) {
            $0.todayStatus.update(
                studySets: scheduleStudySets,
                allUnits: fetchAllUnits,
                toStudyUnits: filterOnlyFailUnits
            )
            $0.reviewSets = scheduleReviewSets
        }
    }
    
}
