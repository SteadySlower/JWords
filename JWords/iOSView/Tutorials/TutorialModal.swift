//
//  TutorialModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI

enum Tutorials: CaseIterable {
    
    case addBook
    case addWord
    case schedule
    case studyView
    case editWord
    case moveWord
    case deleteWord
    case kanjiList
    case scanWord
    
    var title: String {
        switch self {
        case .addBook:
            return "단어장 추가하기"
        case .addWord:
            return "단어 추가하기"
        case .schedule:
            return "복습 스케줄 만들기"
        case .studyView:
            return "단어 공부하기"
        case .editWord:
            return "단어 수정하기"
        case .moveWord:
            return "단어 이동하기"
        case .deleteWord:
            return "단어 삭제하기"
        case .kanjiList:
            return "한자 모아보기"
        case .scanWord:
            return "단어 스캔하기"
        }
    }
    
}

struct TutorialModal: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TutorialModal_Previews: PreviewProvider {
    static var previews: some View {
        TutorialModal()
    }
}
