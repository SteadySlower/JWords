//
//  OCRTest.swift
//  JWordsUnitTests
//
//  Created by Jong Won Moon on 10/16/23.
//

import ComposableArchitecture
import XCTest

@testable import JWords

@MainActor
final class OCRTest: XCTestCase {
    
    func test_getImage_imageFetched() async {
        let koreanOCRResult: [OCRResult] = .testMock
        let japaneseOCRResult: [OCRResult] = .testMock
        
        let store = TestStore(
            initialState: OCR.State(),
            reducer: { OCR() },
            withDependencies: {
                $0.ocrClient.ocr = { _, lang in
                    lang == .korean ? koreanOCRResult : japaneseOCRResult
                }
            }
        )
        
        store.exhaustivity = .off
        
        let image = UIImage()
        
        await store.send(.getImage(.imageFetched(image))) {
            $0.ocr = .init(image: image)
        }
        
        await store.receive {
            $0 == .koreanOcrResponse(.success(koreanOCRResult))
            || $0 == .japaneseOcrResponse(.success(japaneseOCRResult))
        }
        
        await store.receive {
            $0 == .koreanOcrResponse(.success(koreanOCRResult))
            || $0 == .japaneseOcrResponse(.success(japaneseOCRResult))
        }
        
        store.assert {
            $0.ocr?.koreanOcrResult = koreanOCRResult
            $0.ocr?.japaneseOcrResult = japaneseOCRResult
        }
    }
    
}
