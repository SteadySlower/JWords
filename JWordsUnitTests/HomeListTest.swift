////
////  HomeListTest.swift
////  JWordsUnitTests
////
////  Created by JW Moon on 2023/10/04.
////
//
//import ComposableArchitecture
//import XCTest
//
//@testable import JWords
//
//private let fetchSets: [StudySet] = .testMock
//private let fetchSetsNotClosed: [StudySet] = .notClosedTestMock
//private let fetchUnits: [StudyUnit] = .testMock
//
//@MainActor
//final class HomeListTest: XCTestCase {
//    
//    private func setStore() async -> TestStore<HomeList.State, HomeList.Action> {
//        let store = TestStore(
//            initialState: HomeList.State(),
//            reducer: { HomeList() })
//        {
//            $0.studySetClient.fetch = { bool in bool ? fetchSets : fetchSetsNotClosed }
//            $0.studyUnitClient.fetch = { _ in fetchUnits }
//        }
//        
//        await store.send(.onAppear) {
//            $0.sets = fetchSetsNotClosed
//        }
//        
//        return store
//    }
//    
//    func testOnAppear() async {
//        _ = await setStore()
//    }
//    
//    func testHomeCellTapped() async {
//        let store = await setStore()
//        
//        let tappedSet = store.state.sets.randomElement()!
//        
//        await store.send(.homeCellTapped(tappedSet)) {
//            $0.studyUnitsInSet = StudyUnitsInSet.State(set: tappedSet, units: fetchUnits)
//        }
//    }
//    
//    func testSetAddModal() async {
//        let store = await setStore()
//        
//        await store.send(.setAddSetModal(true)) {
//            $0.addSet = AddSet.State()
//            XCTAssertEqual($0.showAddSetModal, true)
//        }
//        
//        await store.send(.setAddSetModal(false)) {
//            $0.addSet = nil
//            XCTAssertEqual($0.showAddSetModal, false)
//        }
//    }
//    
//    func testUpdateIncludeClosed() async {
//        let store = await setStore()
//        
//        XCTAssertEqual(store.state.includeClosed, false)
//        
//        await store.send(.updateIncludeClosed(true)) {
//            $0.includeClosed = true
//        }
//        
//        await store.receive(.onAppear) {
//            $0.sets = fetchSets
//        }
//        
//        await store.send(.updateIncludeClosed(false)) {
//            $0.includeClosed = false
//        }
//        
//        await store.receive(.onAppear) {
//            $0.sets = fetchSetsNotClosed
//        }
//    }
//    
//    func testStudyUnitsInSetDismiss() async {
//        let store = await setStore()
//        
//        XCTAssertEqual(store.state.studyUnitsInSet, nil)
//        
//        let tappedSet = store.state.sets.randomElement()!
//        
//        await store.send(.homeCellTapped(tappedSet)) {
//            $0.studyUnitsInSet = StudyUnitsInSet.State(set: tappedSet, units: fetchUnits)
//        }
//
//        await store.send(.studyUnitsInSet(.dismiss)) {
//            $0.studyUnitsInSet = nil
//        }
//    }
//    
//    func testAddSetAdded() async {
//        let store = await setStore()
//        
//        XCTAssertEqual(store.state.addSet, nil)
//        
//        await store.send(.setAddSetModal(true)) {
//            $0.addSet = AddSet.State()
//        }
//        
//        let addedSet = StudySet(title: Random.string)
//        
//        await store.send(.addSet(.added(addedSet))) {
//            $0.sets.insert(addedSet, at: 0)
//            $0.addSet = nil
//        }
//        
//    }
//    
//    func testAddSetCancel() async {
//        let store = await setStore()
//        
//        XCTAssertEqual(store.state.addSet, nil)
//        
//        await store.send(.setAddSetModal(true)) {
//            $0.addSet = AddSet.State()
//        }
//        
//        await store.send(.addSet(.cancel)) {
//            $0.addSet = nil
//        }
//    }
//}
//
//
