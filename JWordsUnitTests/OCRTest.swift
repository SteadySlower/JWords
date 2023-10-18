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
        
        let image = UIImage(named: "Sample Image")!
        
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
    
    func test_ocr_ocrMarkTapped() async {
        let store = TestStore(
            initialState: OCR.State(
                ocr: GetTextsFromOCR.State(image: UIImage())
            ),
            reducer: { OCR() }
        )
        
        let lang: OCRLang = [.korean, .japanese].randomElement()!
        let text = Random.string
        
        await store.send(.ocr(.ocrMarkTapped(lang, text)))
        
        if lang == .korean {
            await store.receive(.koreanOCR(text))
        } else {
            await store.receive(.japaneseOCR(text))
        }
    }
    
    func test_ocr_removeImageButtonTapped() async {
        let store = TestStore(
            initialState: OCR.State(
                ocr: GetTextsFromOCR.State(image: UIImage())
            ),
            reducer: { OCR() }
        )
        
        await store.send(.ocr(.removeImageButtonTapped)) {
            $0.ocr = nil
        }
    }
    
    func test_japaneseOcrResponse() async {
        let store = TestStore(
            initialState: OCR.State(
                ocr: GetTextsFromOCR.State(image: UIImage())
            ),
            reducer: { OCR() }
        )
        
        let ocrResult: [OCRResult] = .testMock
        
        await store.send(.japaneseOcrResponse(.success(ocrResult))) {
            $0.ocr?.japaneseOcrResult = ocrResult
        }
    }
    
    func test_koreanOcrResponse() async {
        let store = TestStore(
            initialState: OCR.State(
                ocr: GetTextsFromOCR.State(image: UIImage())
            ),
            reducer: { OCR() }
        )
        
        let ocrResult: [OCRResult] = .testMock
        
        await store.send(.koreanOcrResponse(.success(ocrResult))) {
            $0.ocr?.koreanOcrResult = ocrResult
        }
    }
    
}
