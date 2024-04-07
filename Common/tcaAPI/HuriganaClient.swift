//
//  HuriganaClient.swift
//  JWords
//
//  Created by JW Moon on 3/23/24.
//

import Foundation
import ComposableArchitecture
import XCTestDynamicOverlay
import HuriConverter

public struct HuriganaClient {
    private static let converter = HuriganaConverter()
    public var convert: (String) -> String
    public var huriToKanjiText: (String) -> String
    public var extractKanjis: (String) -> [String]
    public var convertToHuris: (String) -> [Huri]
    public var hurisToHurigana: ([Huri]) -> String
}

extension DependencyValues {
    public var huriganaClient: HuriganaClient {
    get { self[HuriganaClient.self] }
    set { self[HuriganaClient.self] = newValue }
  }
}

extension HuriganaClient: DependencyKey {
    public static let liveValue = HuriganaClient(
    convert: { converter.convert($0) },
    huriToKanjiText: { converter.huriToKanjiText(from: $0) },
    extractKanjis: { converter.extractKanjis(from: $0) },
    convertToHuris: { converter.convertToHuris(from: $0) },
    hurisToHurigana: { converter.hurisToHurigana(huris: $0) }
  )
    
}

extension HuriganaClient: TestDependencyKey {
    public static let previewValue = Self(
    convert: { _ in "" },
    huriToKanjiText: { _ in "" },
    extractKanjis: { _ in [""] },
    convertToHuris: { _ in [] },
    hurisToHurigana: { _ in "" }
  )
    
    public static let testValue: HuriganaClient = Self(
    convert: { _ in "" },
    huriToKanjiText: { _ in "" },
    extractKanjis: { _ in [""] },
    convertToHuris: { _ in [] },
    hurisToHurigana: { _ in "" }
  )
}

