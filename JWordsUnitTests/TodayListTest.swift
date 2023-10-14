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
private let updateStudySets: [StudySet] = .testMock
private let updateReviewSets: [StudySet] = .testMock

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
            $0.scheduleClient.updateStudy = { _ in updateStudySets }
            $0.scheduleClient.updateReview = { _ in updateReviewSets }
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
        
        let newFetchAllUnits: [StudyUnit] = .testMock
        let newFilterOnlyFailUnits: [StudyUnit] = .testMock
        
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
