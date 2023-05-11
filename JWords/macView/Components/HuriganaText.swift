//
//  HuriganaText.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI

struct HuriganaText: View {
    private let huris: [Huri]
    private let fontSize: CGFloat
    
    init(hurigana: String, fontSize: CGFloat = 20) {
        self.huris = hurigana.split(separator: "`").map { Huri(String($0)) }
        self.fontSize = fontSize
    }

    var body: some View {
        CenterFlexBox(horizontalSpacing: 0, verticalSpacing: fontSize / 2) {
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
