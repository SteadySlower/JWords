//
//  HuriganaText.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI

private struct Huri: Identifiable, Equatable {
    let id = UUID()
    let kanji: String
    let gana: String
    
    init(_ huriString: String) {
        if huriString.contains(where: { $0 == Character(String.huriganaFrom) }) {
            let kanjiAndGana = huriString.split(separator: Character(String.huriganaFrom))
            self.kanji = String(kanjiAndGana[0])
            self.gana = String(kanjiAndGana[1].dropLast())
        } else {
            self.kanji = ""
            self.gana = huriString
        }
        
    }
}



struct HuriganaText: View {
    private let huris: [Huri]
    private let fontSize: CGFloat
    
    init(hurigana: String, fontSize: CGFloat = 20) {
        self.huris = hurigana.split(separator: "`").map { Huri(String($0)) }
        self.fontSize = fontSize
    }

    var body: some View {
        WrappingHStack(horizontalSpacing: 0, verticalSpacing: fontSize / 2) {
            ForEach(huris) { huri in
                huriView(for: huri)
            }
        }
        .padding(.top, fontSize / 2)
    }
    
    @ViewBuilder
    private func huriView(for huri: Huri) -> some View {
        if !huri.kanji.isEmpty {
            ZStack {
                Text(huri.kanji)
                    .font(.system(size: fontSize))
                Text(huri.gana)
                    .font(.system(size: fontSize / 2))
                    .lineLimit(1)
                    .offset(y: -fontSize / 1.2)
            }
        } else {
            Text(huri.gana)
                .font(.system(size: fontSize))
        }
    }
}
