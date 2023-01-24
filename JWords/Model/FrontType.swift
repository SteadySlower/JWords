//
//  FrontType.swift
//  JWords
//
//  Created by JW Moon on 2023/01/23.
//

enum FrontType: Int, Hashable, CaseIterable {
    case kanji
    case meaning
    
    var pickerText: String {
        switch self {
        case .meaning:
            return "한"
        case .kanji:
            return "漢"
        }
    }
    
    var preferredTypeText: String {
        switch self {
        case .meaning: return "한 -> 日"
        case .kanji: return "日 -> 한"
        }
    }
}
