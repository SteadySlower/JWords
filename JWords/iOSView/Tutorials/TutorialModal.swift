//
//  TutorialModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI

enum Tutorial: CaseIterable {
    
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
        ScrollView {
            VStack {
                Text("튜토리얼 보기")
                    .font(.title)
                    .leadingAlignment()
                    .padding(.bottom, 10)
                ForEach(Tutorial.allCases, id: \.self.title) { tutorial in
                    tutorialCell(tutorial)
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private func tutorialCell(_ tutorial: Tutorial) -> some View {
        Button {
            print("디버그: \(tutorial.title) Tapped")
        } label: {
            HStack {
                Text(tutorial.title)
                    .font(.title3)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 20)
            .defaultRectangleBackground()
        }
    }
}

struct TutorialModal_Previews: PreviewProvider {
    static var previews: some View {
        TutorialModal()
    }
}
