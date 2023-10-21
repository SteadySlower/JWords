//
//  StudyOneUnitTest.swift
//  JWordsUnitTests
//
//  Created by JW Moon on 10/21/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class StudyOneUnitTest: XCTestCase {
    
    func test_cellTapped() async {
        let store = TestStore(
            initialState: StudyOneUnit.State(unit: .testMock),
            reducer: { StudyOneUnit() }
        )
        
        for _ in 0..<Random.int(from: 1, to: 10) {
            await store.send(.cellTapped) {
                $0.isFront.toggle()
            }
        }
    }
    
}
