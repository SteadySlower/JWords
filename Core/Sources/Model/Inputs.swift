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
    
    public init(title: String, isAutoSchedule: Bool, preferredFrontType: FrontType) {
        self.title = title
        self.isAutoSchedule = isAutoSchedule
        self.preferredFrontType = preferredFrontType
    }
}

public struct StudyUnitInput {
    public let type: UnitType
    public let kanjiText: String
    public let meaningText: String
    
    public init(type: UnitType, kanjiText: String, meaningText: String) {
        self.type = type
        self.kanjiText = kanjiText
        self.meaningText = meaningText
    }
}

public struct StudyKanjiInput {
    public let kanjiText: String
    public let meaningText: String
    public let ondoku: String
    public let kundoku: String
    
    public init(kanjiText: String, meaningText: String, ondoku: String, kundoku: String) {
        self.kanjiText = kanjiText
        self.meaningText = meaningText
        self.ondoku = ondoku
        self.kundoku = kundoku
    }
}
