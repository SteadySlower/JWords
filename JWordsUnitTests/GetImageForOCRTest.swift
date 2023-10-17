//
//  GetImageForOCRTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/17/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class GetImageForOCRTest: XCTestCase {
    
    func test_clipBoardButtonTapped() async {
        let image = UIImage()
        let store = TestStore(
            initialState: GetImageForOCR.State(),
            reducer: { GetImageForOCR() },
            withDependencies: {
                $0.pasteBoardClient.fetchImage = { UIImage() }
                $0.utilClient.resizeImage = { _ in image }
            }
        )
        
        await store.send(.clipBoardButtonTapped)
        await store.receive(.imageFetched(image))
    }
    
    func test_cameraButtonTapped() async {
        let store = TestStore(
            initialState: GetImageForOCR.State(),
            reducer: { GetImageForOCR() }
        )
        
        await store.send(.cameraButtonTapped) {
            $0.showCameraScanner = true
        }
    }
    
    func test_showCameraScanner() async {
        var bool = Bool.random()
        
        let store = TestStore(
            initialState: GetImageForOCR.State(
                showCameraScanner: bool
            ),
            reducer: { GetImageForOCR() }
        )
        
        store.exhaustivity = .off
        
        bool.toggle()
        await store.send(.showCameraScanner(bool))
        
        store.assert {
            $0.showCameraScanner = bool
        }
    }
    
    func test_cameraImageSelected() async {
        let image = UIImage(named: "Sample Image")!
        let store = TestStore(
            initialState: GetImageForOCR.State(),
            reducer: { GetImageForOCR() },
            withDependencies: {
                $0.utilClient.resizeImage = { _ in image }
            }
        )
        
        await store.send(.cameraImageSelected(UIImage()))
        await store.receive(.imageFetched(image))
    }
    
}
