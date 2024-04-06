//
//  HuriganaText.swift
//  Huri
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import Huri

public struct HuriganaText: View {
    private let huris: [Huri]
    private let fontSize: CGFloat
    private let hideYomi: Bool
    private let alignment: FlexBox.Alignment
    
    public init(
        hurigana: String,
        fontSize: CGFloat = 20,
        hideYomi: Bool = false,
        isCenter: Bool = true
    ) {
        self.huris = hurigana
            .split(separator: String.betweenHurigana)
            .enumerated()
            .map { (index, huriString) in
                Huri(id: "\(index)\(huriString)", huriString: String(huriString))
            }
        self.fontSize = fontSize
        self.hideYomi = hideYomi
        self.alignment = isCenter ? .center : .leading
    }

    public var body: some View {
        FlexBox(horizontalSpacing: 0, verticalSpacing: fontSize / 2, alignment: alignment) {
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
                    .opacity(hideYomi ? 0 : 1)
            }
        } else {
            Text(huri.gana)
                .font(.system(size: fontSize))
        }
    }
}
