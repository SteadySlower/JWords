//
//  OCRClient.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import Model
import OCRKit

public struct OCRClient {
    private static let ocr = OCRService.shared
    public var ocr: @Sendable (InputImageType, OCRLang) async throws -> [OCRResult]
    
    public static let liveValue = OCRClient(
    ocr: { image, lang in
        try await ocr.ocr(from: image, lang: lang)
    }
  )
    
    public static let previewValue = Self(
    ocr: { _, _ in [] }
  )
    
    public static let testValue: OCRClient = Self(
    ocr: { _, _ in [] }
  )
}


