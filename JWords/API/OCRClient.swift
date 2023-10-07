//
//  OCRClient.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import ComposableArchitecture
import XCTestDynamicOverlay

struct OCRClient {
    private static let ocr = OCRService.shared
    var ocr: @Sendable (InputImageType, OCRLang) async throws -> [OCRResult]
}

extension DependencyValues {
  var ocrClient: OCRClient {
    get { self[OCRClient.self] }
    set { self[OCRClient.self] = newValue }
  }
}

extension OCRClient: DependencyKey {
  static let liveValue = OCRClient(
    ocr: { image, lang in
        try await ocr.ocr(from: image, lang: lang)
    }
  )
}

extension OCRClient: TestDependencyKey {
  static let previewValue = Self(
    ocr: { _, _ in [] }
  )

  static let testValue = Self(
    ocr: { _, _ in [] }
  )
}
