//
//  AddSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class AddSetTest: XCTestCase {
    
    @MainActor
    func test_add() async {
        let set: StudySet = .testMock
        
        let store = TestStore(
            initialState: AddSet.State(),
            reducer: { AddSet() },
            withDependencies: {
                $0.studySetClient.insert = { _ in set }
            }
        )
        
        await store.send(.add)
        await store.receive(.added(set))
    }
    
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: AddSet.State(),
            reducer: { AddSet() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}
