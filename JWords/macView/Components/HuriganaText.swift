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
        GeometryReader { geometry in
            self.generateContent(in: geometry)
        }
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(huris, id: \.id) { huri in
                self.item(for: huri)
                    .padding(.vertical, 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width)
                        {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if huri == self.huris.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if huri == self.huris.last! {
                            height = 0 // last item
                        }
                        return result
                    })
            }
        }
    }

    @ViewBuilder
    private func item(for huri: Huri) -> some View {
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
