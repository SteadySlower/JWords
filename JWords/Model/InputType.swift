//
//  InputType.swift
//  JWords
//
//  Created by JW Moon on 2023/03/19.
//

enum InputType: Hashable, CaseIterable {
    case meaning, kanji, gana
    
    var description: String {
        switch self {
        case .meaning: return "뜻"
        case .gana: return "가나"
        case .kanji: return "한자"
        }
    }
}
