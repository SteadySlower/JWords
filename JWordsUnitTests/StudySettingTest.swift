//
//  StudySettingTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/18/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class StudySettingTest: XCTestCase {
    
    func test_setFrontType() async {
        let currentFrontType = FrontType.allCases.randomElement()!
        let store = TestStore(
            initialState: StudySetting.State(
                showSetEditButtons: Bool.random(),
                frontType: currentFrontType,
                selectableListType: .testMock
            ),
            reducer: { StudySetting() }
        )
        
        let newFrontType = FrontType.allCases.filter { $0 != currentFrontType }.randomElement()!
        
        await store.send(.setFrontType(newFrontType)) {
            $0.frontType = newFrontType
        }
    }
    
}
