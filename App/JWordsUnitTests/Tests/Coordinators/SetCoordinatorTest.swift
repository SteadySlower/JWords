//
//  SetCoordinatorTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 3/17/24.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class SetCoordinatorTest: XCTestCase {
    @MainActor
    func test_homeList_toStudySet() async {
        let units: [StudyUnit] = .testMock
        let store = TestStore(
            initialState: SetCoordinator.State(),
            reducer: { SetCoordinator() },
            withDependencies: {
                $0.studyUnitClient.fetch = { _ in units }
            }
        )
        let set: StudySet = .testMock
        await store.send(\.homeList.toStudySet, set) {
            $0.path.append(.studyUnitsInSet(StudyUnitsInSet.State(set: set, units: units)))
        }
    }
    
    @MainActor
    func test_path_element_studyUnitsInSet_unitsMoved() async {
        let store = TestStore(
            initialState: SetCoordinator.State(path: StackState([
                .studyUnitsInSet(.init(set: .testMock, units: .testMock))
            ])),
            reducer: { SetCoordinator() }
        )
        await store.send(\.path[id: 0].studyUnitsInSet.modals.unitsMoved) {
            $0.path.pop(from: 0)
        }
    }
}
