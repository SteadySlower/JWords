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

private struct WrappingHStack: Layout {
    private var horizontalSpacing: CGFloat
    private var verticalSpacing: CGFloat
    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat? = nil) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing ?? horizontalSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }

        let height = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0

        var rowWidths = [CGFloat]()
        var currentRowWidth: CGFloat = 0
        subviews.forEach { subview in
            if currentRowWidth + horizontalSpacing + subview.sizeThatFits(proposal).width >= proposal.width ?? 0 {
                rowWidths.append(currentRowWidth)
                currentRowWidth = subview.sizeThatFits(proposal).width
            } else {
                currentRowWidth += horizontalSpacing + subview.sizeThatFits(proposal).width
            }
        }
        rowWidths.append(currentRowWidth)

        let rowCount = CGFloat(rowWidths.count)
        return CGSize(width: max(rowWidths.max() ?? 0, proposal.width ?? 0), height: rowCount * height + (rowCount - 1) * verticalSpacing)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let height = subviews.map { $0.dimensions(in: proposal).height }.max() ?? 0
        guard !subviews.isEmpty else { return }
        var x = bounds.minX
        var y = height / 2 + bounds.minY
        subviews.forEach { subview in
            x += subview.dimensions(in: proposal).width / 2
            if x + subview.dimensions(in: proposal).width / 2 > bounds.maxX {
                x = bounds.minX + subview.dimensions(in: proposal).width / 2
                y += height + verticalSpacing
            }
            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .center,
                proposal: ProposedViewSize(
                    width: subview.dimensions(in: proposal).width,
                    height: subview.dimensions(in: proposal).height
                )
            )
            x += subview.dimensions(in: proposal).width / 2 + horizontalSpacing
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
