//
//  KanjiCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI

struct KanjiCell: View {
    
    private let kanji: Kanji
    private let editKanjiMeaning: (Kanji, String) -> Void
    private let wordButtonTapped: () -> Void
    
    @State var meaningText: String = ""
    @State var isEditing: Bool = false
    
    init(kanji: Kanji, editKanjiMeaning: @escaping (Kanji, String) -> Void, wordButtonTapped: @escaping () -> Void) {
        self.kanji = kanji
        self.editKanjiMeaning = editKanjiMeaning
        self.wordButtonTapped = wordButtonTapped
    }
    
    var body: some View {
        ZStack {
            HStack {
                VStack(spacing: 10) {
                    Text(kanji.kanjiText ?? "")
                        .font(.system(size: 40))
                    if isEditing {
                        meaningField
                    } else {
                        Text(kanji.meaningText ?? "❓")
                            .font(.system(size: 20))
                    }
                }
            }
            HStack {
                Spacer()
                VStack(spacing: 10) {
                    Button("✏️") {
                        meaningText = kanji.meaningText ?? ""
                        isEditing = true
                    }
                    Button("단어 보기") {
                        wordButtonTapped()
                    }
                }
            }
        }
        .frame(width: Constants.Size.deviceWidth * 0.9)
        .padding(.vertical, 5)
        .border(.black)
        .padding(.vertical, 5)
    }
    
    private var meaningField: some View {
        HStack {
            TextField("뜻 입력", text: $meaningText)
                .frame(width: Constants.Size.deviceWidth * 0.3)
                .border(.black)
            Button("입력") {
                isEditing = false
                editKanjiMeaning(kanji, meaningText)
            }
        }
    }
    
}
