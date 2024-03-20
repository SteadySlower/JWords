//
//  TodayCoordinatorTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class TodayCoordinatorTest: XCTestCase {
    
    @MainActor
    func test_todayList_toStudyFilteredUnits() async {
        let store = TestStore(
            initialState: TodayCoordinator.State(),
            reducer: { TodayCoordinator() }
        )
        let units: [StudyUnit] = .testMock
        await store.send(.todayList(.toStudyFilteredUnits(units))) {
            $0.path.append(.studyUnits(StudyUnits.State(units: units)))
        }
    }
    
    @MainActor
    func test_todayList_toStudySet() async {
        let units: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: TodayCoordinator.State(),
            reducer: { TodayCoordinator() },
            withDependencies: {
                $0.studyUnitClient.fetch = { _ in units }
            }
        )
        let set: StudySet = .testMock
        await store.send(.todayList(.toStudySet(set))) {
            $0.path.append(.studyUnitsInSet(StudyUnitsInSet.State(set: set, units: units)))
        }
    }
    
    @MainActor
    func test_todayList_showTutorial() async {
        let store = TestStore(
            initialState: TodayCoordinator.State(),
            reducer: { TodayCoordinator() }
        )
        await store.send(.todayList(.showTutorial)) {
            $0.path.append(.tutorial(ShowTutorial.State()))
        }
    }
    
    @MainActor
    func test_path_element_studyUnitsInSet_modals_unitsMoved() async {
        let store = TestStore(
            initialState: TodayCoordinator.State(
                path: StackState([
                    .studyUnitsInSet(.init(set: .testMock, units: .testMock))
                ])
            ),
            reducer: { TodayCoordinator() }
        )
        await store.send(.path(.element(id: 0, action: .studyUnitsInSet(.modals(.unitsMoved))))) {
            $0.path.pop(from: 0)
        }
    }
}
