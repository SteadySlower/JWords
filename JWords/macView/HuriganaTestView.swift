//
//  HuriganaTestView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI

struct HuriganaTestView: View {
    
    @Environment(\.sizeCategory) var sizeCategory
    @State private var screenSize = CGFloat.zero
    
    @State var text: String = ""
    @State var hurigana: String = ""
    
    var body: some View {
        ZStack {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { screenSize = proxy.size.width }
                    .onChange(of: proxy.size.width) { screenSize = $0 }
            }
            VStack {
                Text(hurigana)
                    .padding(.bottom, 20)
                HuriganaText(hurigana, screenSize: screenSize)
                TextField("", text: $text)
                    .onChange(of: text) { hurigana = HuriganaConverter.shared.convert($0) }
            }
        }

    }
}

struct Huri: Identifiable {
    let id = UUID()
    let kanji: String
    let gana: String
    
    init(_ huriString: String) {
        if huriString.contains(where: { $0 == "[" }) {
            let kanjiAndGana = huriString.split(separator: "[")
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
    private let screenSize: CGFloat
    
    init(_ hurigana: String, _ fontSize: CGFloat = 20, screenSize: CGFloat) {
        self.huris = hurigana.split(separator: "`").map { Huri(String($0)) }
        self.fontSize = fontSize
        self.screenSize = screenSize
    }
    
    var body: some View {
//        HStack(spacing: 0) {
//            ForEach(huris) { huri in
//                if !huri.kanji.isEmpty {
//                    ZStack {
//                        Text(huri.kanji)
//                            .font(.system(size: fontSize))
//                        Text(huri.gana)
//                            .font(.system(size: fontSize / 2))
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.1)
//                            .offset(y: -fontSize / 1.2)
//                    }
//                } else {
//                    Text(huri.gana)
//                        .font(.system(size: fontSize))
//                }
//            }
//        }
        CustomHStack(content: huris.map { AnyView(makeHuriView($0)) })
    }
    
    @ViewBuilder
    func makeHuriView(_ huri: Huri) -> some View {
        if !huri.kanji.isEmpty {
            ZStack {
                Text(huri.kanji)
                    .font(.system(size: fontSize))
                Text(huri.gana)
                    .font(.system(size: fontSize / 2))
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .offset(y: -fontSize / 1.2)
            }
        } else {
            Text(huri.gana)
                .font(.system(size: fontSize))
        }
    }

}

struct HuriganaTestView_Previews: PreviewProvider {
    static var previews: some View {
        HuriganaTestView()
    }
}

extension AnyView {
    var uid: UUID {
        UUID()
    }
}


struct CustomHStack: View {
    @State private var availableWidth: CGFloat = 0
    @State private var wrappedLines: Int = 1

    var content: [AnyView]
    
    init(content: [AnyView]) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                ForEach(0..<wrappedLines, id: \.self) { lineNumber in
                    HStack(spacing: 0) {
                        ForEach(getContentForLine(lineNumber), id: \.uid) { item in
                            item
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(width: availableWidth, alignment: .leading)
                }
            }
            .onAppear {
                availableWidth = geometry.size.width
                updateWrappedLines()
            }
            .onChange(of: geometry.size.width) { _ in
                availableWidth = geometry.size.width
                updateWrappedLines()
            }
        }
    }

    private func getContentForLine(_ lineNumber: Int) -> [AnyView] {
        let start = lineNumber * itemsPerLine()
        let end = min(start + itemsPerLine(), content.count)

        return Array(content[start..<end])
    }

    private func itemsPerLine() -> Int {
        let itemWidth: CGFloat = 100 // adjust as needed
        return max(Int(floor(availableWidth / itemWidth)), 1)
    }

    private func updateWrappedLines() {
        wrappedLines = Int(ceil(CGFloat(content.count) / CGFloat(itemsPerLine())))
    }
}
