//
//  Inputs.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Foundation

public struct StudySetInput {
    public let title: String
    public let isAutoSchedule: Bool
    public let preferredFrontType: FrontType
}

public struct StudyUnitInput {
    public let type: UnitType
    public let kanjiText: String
    public let meaningText: String
}

public struct StudyKanjiInput {
    public let kanjiText: String
    public let meaningText: String
    public let ondoku: String
    public let kundoku: String
}
