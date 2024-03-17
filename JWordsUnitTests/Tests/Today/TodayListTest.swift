//
//  TodayListTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 2023/10/05.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class TodayListTest: XCTestCase {

    @MainActor
    func test_fetchSetsAndSchedule() async -> TestStore<TodayList.State, TodayList.Action> {
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
        }

        await store.send(.fetchSetsAndSchedule) {
            $0.todayStatus.update(
                studySets: scheduleStudySets,
                allUnits: fetchAllUnits,
                toStudyUnits: filterOnlyFailUnits
            )
            $0.reviewSets = scheduleReviewSets
        }
        
        return store
    }
    
    @MainActor
    func test_toSetSchedule() async {
        let store = TestStore(initialState: TodayList.State()) {
            TodayList()
        } withDependencies: {
            $0.studySetClient.fetch = { _ in .testMock }
            $0.studyUnitClient.fetchAll = { _ in .testMock }
            $0.scheduleClient.study = { _ in .notClosedTestMock }
            $0.scheduleClient.review = { _ in .notClosedTestMock }
            $0.utilClient.filterOnlyFailUnits = { _ in .testMock }
        }
        
        await store.send(.toSetSchedule) {
            $0.destination = .todaySelection(TodaySelection.State(todaySets: $0.todayStatus.studySets, reviewSets: $0.reviewSets))
            $0.clear()
        }
    }
    
    @MainActor
    func test_destination_dismiss_todaySelection() async {
        let updatedStudySets: [StudySet] = .testMock
        let updatedReviewSets: [StudySet] = .testMock
        let newlyFetchedAllUnits: [StudyUnit] = .testMock
        let newlyFilteredOnlyFailUnits: [StudyUnit] = .testMock
        
        let store = TestStore(initialState: TodayList.State()) {
            TodayList()
        } withDependencies: {
            $0.scheduleClient.updateStudy = { _ in updatedStudySets }
            $0.scheduleClient.updateReview = { _ in updatedReviewSets }
            $0.studyUnitClient.fetchAll = { _ in newlyFetchedAllUnits }
            $0.utilClient.filterOnlyFailUnits = { _ in newlyFilteredOnlyFailUnits }
        }
        
        await store.send(.toSetSchedule) {
            $0.destination = .todaySelection(TodaySelection.State(todaySets: $0.todayStatus.studySets, reviewSets: $0.reviewSets))
            $0.clear()
        }
        
        await store.send(.destination(.dismiss)) {
            $0.todayStatus.update(
                studySets: updatedStudySets,
                allUnits: newlyFetchedAllUnits,
                toStudyUnits: newlyFilteredOnlyFailUnits
            )
            $0.reviewSets = updatedReviewSets
            $0.destination = nil
        }
    }
    
    @MainActor
    func test_todayStatus_onTapped_when_todayStatus_isEmpty() async {
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
            $0.scheduleClient.autoSet = { _ in }
        }
        
        await store.send(.todayStatus(.onTapped)) {
            $0.todayStatus.update(
                studySets: scheduleStudySets,
                allUnits: fetchAllUnits,
                toStudyUnits: filterOnlyFailUnits
            )
            $0.reviewSets = scheduleReviewSets
        }
    }
    
    @MainActor
    func test_todayStatus_onTapped_when_todayStatus_not_isEmpty() async {
        let toStudyUnits: [StudyUnit] = .testMock
        
        let store = TestStore(
            initialState: TodayList.State(
                todayStatus: .init(studySets: .testMock, toStudyUnits: toStudyUnits)
            ),
            reducer: { TodayList() }
        )

        await store.send(.todayStatus(.onTapped))
        await store.receive(.toStudyFilteredUnits(toStudyUnits))
    }
    
    @MainActor
    func test_clearSchedule() async {
        let store = TestStore(
            initialState: TodayList.State(
                todayStatus: .init(
                    studySets: .testMock,
                    allUnits: .testMock,
                    toStudyUnits: .testMock
                )
            ),
            reducer: { TodayList() },
            withDependencies: {
                $0.scheduleClient.clear = {}
            }
        )
        
        await store.send(.clearSchedule) {
            $0.clear()
        }
    }

}

