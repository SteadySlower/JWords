//
//  GetImageForOCRTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/17/23.
//

import ComposableArchitecture
import XCTest
@testable import JWords

final class GetImageForOCRTest: XCTestCase {
    
    @MainActor
    func test_getImageFromClipboard() async {
        let image = UIImage(named: "Sample Image")!
        let store = TestStore(
            initialState: GetImageForOCR.State(),
            reducer: { GetImageForOCR() },
            withDependencies: {
                $0.pasteBoardClient.fetchImage = { UIImage() }
                $0.utilClient.resizeImage = { _ in image }
            }
        )
        
        await store.send(.getImageFromClipboard)
        await store.receive(.imageFetched(image))
    }
    
    @MainActor
    func test_getImageFromCamera() async {
        let store = TestStore(
            initialState: GetImageForOCR.State(),
            reducer: { GetImageForOCR() }
        )
        
        await store.send(.getImageFromCamera) {
            $0.destination = .cameraScanner(.init())
        }
    }

    @MainActor
    func test_destination_presented_cameraScanner_imageSelected() async {
        let image = UIImage(named: "Sample Image")!
        let store = TestStore(
            initialState: GetImageForOCR.State(
                destination: .cameraScanner(.init())
            ),
            reducer: { GetImageForOCR() },
            withDependencies: {
                $0.utilClient.resizeImage = { _ in image }
            }
        )
        
        await store.send(.destination(.presented(.cameraScanner(.imageSelected(UIImage())))))
        await store.receive(.imageFetched(image))
    }
    
}
