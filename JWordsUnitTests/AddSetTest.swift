//
//  AddSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class AddSetTest: XCTestCase {
    
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
    
}
