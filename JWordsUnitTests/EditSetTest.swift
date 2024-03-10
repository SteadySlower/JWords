//
//  EditSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords


final class EditSetTest: XCTestCase {
    
    @MainActor
    func test_edit() async {
        let set: StudySet = .testMock
        let store = TestStore(
            initialState: EditSet.State(.testMock),
            reducer: { EditSet() },
            withDependencies: {
                $0.studySetClient.update = { _, _ in set }
            })
        
        await store.send(.edit)
        
        await store.receive(.edited(set))
    }
    
    @MainActor
    func test_cancel() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: EditSet.State(.testMock),
            reducer: { EditSet() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        
        await store.send(.cancel)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}
