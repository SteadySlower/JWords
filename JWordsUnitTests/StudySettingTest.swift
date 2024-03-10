//
//  StudySettingTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/18/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class StudySettingTest: XCTestCase {
    
    @MainActor
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
    
    @MainActor
    func test_setFilter() async {
        let store = TestStore(
            initialState: StudySetting.State(
                showSetEditButtons: Bool.random(),
                frontType: FrontType.allCases.randomElement()!,
                selectableListType: .testMock
            ),
            reducer: { StudySetting() }
        )
        
        let newFilter = UnitFilter.allCases.filter { $0 != store.state.filter }.randomElement()!
        
        await store.send(.setFilter(newFilter)) {
            $0.filter = newFilter
        }
    }
    
    @MainActor
    func test_setListType() async {
        let selectableListType: [ListType] = .testMock
        let store = TestStore(
            initialState: StudySetting.State(
                showSetEditButtons: Bool.random(),
                frontType: FrontType.allCases.randomElement()!,
                selectableListType: selectableListType
            ),
            reducer: { StudySetting() }
        )
        
        store.assert {
            $0.listType = .study
        }
        
        let newType = selectableListType.filter { $0 != .study }.randomElement()!
        
        await store.send(.setListType(newType)) {
            $0.listType = newType
        }
    }
    
}
