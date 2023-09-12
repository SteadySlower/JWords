//
//  FrontType.swift
//  JWords
//
//  Created by JW Moon on 2023/01/23.
//

enum FrontType: Int, Equatable, Hashable, CaseIterable {
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
        case .meaning: return "뜻 앞면"
        case .kanji: return "일본어 앞면"
        }
    }
}
