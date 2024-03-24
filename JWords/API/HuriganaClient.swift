//
//  HuriganaClient.swift
//  JWords
//
//  Created by JW Moon on 3/23/24.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import Huri

struct HuriganaClient {
    private static let converter = HuriganaConverter()
    var convert: (String) -> String
    var huriToKanjiText: (String) -> String
    var extractKanjis: (String) -> [String]
    var convertToHuris: (String) -> [Huri]
}

extension DependencyValues {
  var huriganaClient: HuriganaClient {
    get { self[HuriganaClient.self] }
    set { self[HuriganaClient.self] = newValue }
  }
}

extension HuriganaClient: DependencyKey {
  static let liveValue = HuriganaClient(
    convert: { converter.convert($0) },
    huriToKanjiText: { converter.huriToKanjiText(from: $0) },
    extractKanjis: { converter.extractKanjis(from: $0) },
    convertToHuris: { converter.convertToHuris(from: $0) }
  )
}

extension HuriganaClient: TestDependencyKey {
  static let previewValue = Self(
    convert: { _ in "" },
    huriToKanjiText: { _ in "" },
    extractKanjis: { _ in [""] },
    convertToHuris: { _ in [] }
  )
}

