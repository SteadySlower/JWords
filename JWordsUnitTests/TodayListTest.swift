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
        let fetchSets: [StudySet] = .testMock
        let fetchAllUnits: [StudyUnit] = .testMock
        let scheduleStudySets: [StudySet] = .notClosedTestMock
        let scheduleReviewSets: [StudySet] = .notClosedTestMock
        let filterOnlyFailUnits: [StudyUnit] = .testMock
        
        let store = TestStore(initialState: TodayList.State()) {
            TodayList()
        } withDependencies: {
            $0.studySetClient.fetch = { _ in fetchSets }
            $0.studyUnitClient.fetchAll = { _ in fetchAllUnits }
            $0.scheduleClient.study = { _ in scheduleStudySets }
            $0.scheduleClient.review = { _ in scheduleReviewSets }
            $0.utilClient.filterOnlyFailUnits = { _ in filterOnlyFailUnits }
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
        _ = await setTestStore()
    }
    
    func testListButtonTapped() async {
        let store = await setTestStore()
        
        await store.send(.listButtonTapped) {
            $0.todaySelection = TodaySelection.State(
                todaySets: $0.todayStatus.studySets,
                reviewSets: $0.reviewSets
            )
            $0.todayStatus.clear()
            $0.reviewSets = []
        }
    }
    
    func testSetSelectionModalFalse() async {
        let store = await setTestStore()
        
        await store.send(.listButtonTapped) {
            $0.todaySelection = TodaySelection.State(
                todaySets: $0.todayStatus.studySets,
                reviewSets: $0.reviewSets
            )
            $0.todayStatus.clear()
            $0.reviewSets = []
        }
        
        let updateStudySets: [StudySet] = .testMock
        let updateReviewSets: [StudySet] = .testMock
        let newFetchAllUnits: [StudyUnit] = .testMock
        let newFilterOnlyFailUnits: [StudyUnit] = .testMock
        
        store.dependencies.scheduleClient.updateStudy = { _ in updateStudySets }
        store.dependencies.scheduleClient.updateReview = { _ in updateReviewSets }
        store.dependencies.studyUnitClient.fetchAll = { _ in newFetchAllUnits }
        store.dependencies.utilClient.filterOnlyFailUnits = { _ in newFilterOnlyFailUnits }
        
        await store.send(.setSelectionModal(false)) {
            $0.todayStatus.update(
                studySets: updateStudySets,
                allUnits: newFetchAllUnits,
                toStudyUnits: newFilterOnlyFailUnits
            )
            $0.reviewSets = updateReviewSets
            $0.todaySelection = nil
        }
    }
    
}
