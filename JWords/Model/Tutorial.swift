//
//  Tutorial.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import Foundation

enum Tutorial: CaseIterable {
    case addSet
    case addUnit
    case schedule
    case studyView
    case editUnit
    case moveUnit
    case deleteUnit
    case kanjiList
    case scanUnit
    
    var title: String {
        switch self {
        case .addSet:
            return "단어장 추가하기"
        case .addUnit:
            return "단어 추가하기"
        case .schedule:
            return "복습 스케줄 만들기"
        case .studyView:
            return "단어 공부하기"
        case .editUnit:
            return "단어 수정하기"
        case .moveUnit:
            return "단어 이동하기"
        case .deleteUnit:
            return "단어 삭제하기"
        case .kanjiList:
            return "한자 모아보기"
        case .scanUnit:
            return "단어 스캔하기"
        }
    }
    
    var imageName: String {
        switch self {
        case .addSet:
            return "Add Set"
        case .addUnit:
            return "Add Unit"
        case .schedule:
            return "Schedule"
        case .studyView:
            return "Study View"
        case .editUnit:
            return "Edit Unit"
        case .moveUnit:
            return "Move Unit"
        case .deleteUnit:
            return "Delete Unit"
        case .kanjiList:
            return "Kanji List"
        case .scanUnit:
            return "Scan Unit"
        }
    }
    
    var imageCount: Int {
        switch self {
        case .addSet:
            return 4
        case .addUnit:
            return 8
        case .schedule:
            return 8
        case .studyView:
            return 7
        case .editUnit:
            return 3
        case .moveUnit:
            return 5
        case .deleteUnit:
            return 2
        case .kanjiList:
            return 2
        case .scanUnit:
            return 3
        }
    }
}
