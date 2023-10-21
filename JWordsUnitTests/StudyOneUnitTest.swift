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
    
    func test_cellDoubleTapped() async {
        let testMock: StudyUnit = [.successTestMock, .failTestMock].randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(unit: testMock),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, state in state }
            }
        )
        
        await store.send(.cellDoubleTapped) {
            $0.studyState = .undefined
        }
    }
    
    func test_cellDoubleTapped_locked() async {
        let testMock: StudyUnit = [.successTestMock, .failTestMock].randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: testMock,
                isLocked: true
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, state in state }
            }
        )
        
        await store.send(.cellDoubleTapped)
    }
    
    func test_cellDrag_left() async {
        let testMock: StudyUnit = [.undefinedTestMock, .failTestMock].randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: testMock
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, state in state }
            }
        )
        
        await store.send(.cellDrag(direction: .left)) {
            $0.studyState = .success
        }
    }
    
    func test_cellDrag_left_locked() async {
        let testMock: StudyUnit = [.undefinedTestMock, .failTestMock].randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: testMock,
                isLocked: true
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, state in state }
            }
        )
        
        await store.send(.cellDrag(direction: .left))
    }
    
    func test_cellDrag_right() async {
        let testMock: StudyUnit = [.undefinedTestMock, .successTestMock].randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: testMock
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, state in state }
            }
        )
        
        await store.send(.cellDrag(direction: .right)) {
            $0.studyState = .fail
        }
    }
    
    func test_cellDrag_right_locked() async {
        let testMock: StudyUnit = [.undefinedTestMock, .successTestMock].randomElement()!
        
        let store = TestStore(
            initialState: StudyOneUnit.State(
                unit: testMock,
                isLocked: true
            ),
            reducer: { StudyOneUnit() },
            withDependencies: {
                $0.studyUnitClient.studyState = { _, state in state }
            }
        )
        
        await store.send(.cellDrag(direction: .right))
    }
    
}
