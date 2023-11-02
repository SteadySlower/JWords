//
//  SelectionStudySetTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 11/2/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class SelectionStudySetTest: XCTestCase {
    
    func testOnAppear() async {
        let sets: [StudySet] = .testMock
        let store = TestStore(
            initialState: SelectStudySet.State(),
            reducer: { SelectStudySet() },
            withDependencies: {
                $0.studySetClient.fetch = { _ in sets }
            }
        )
        
        await store.send(.onAppear) {
            $0.sets = sets
        }
    }
    
}
