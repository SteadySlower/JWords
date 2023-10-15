//
//  EditSetTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/15/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class EditSetTest: XCTestCase {
    
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
    
}
