//
//  HuriganaTestView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI

struct HuriganaTestView: View {
    
    @State var text: String = ""
    @State var hurigana: String = ""
    
    var body: some View {
        VStack {
            Text(hurigana)
                .padding(.bottom, 20)
            HuriganaText(hurigana)
            TextField("", text: $text)
                .onChange(of: text) { hurigana = HuriganaConverter.shared.convert($0) }
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
    
    init(_ hurigana: String, _ fontSize: CGFloat = 20) {
        self.huris = hurigana.split(separator: "`").map { Huri(String($0)) }
        self.fontSize = fontSize
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(huris) { huri in
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
    }
    
    //                    Text(huri.kanji)
    //                        .font(.system(size: fontSize))
    //                        .overlay {
    //                            Text(huri.gana)
    //                                .font(.system(size: fontSize / 2))
    //                                .lineLimit(1)
    //                                .minimumScaleFactor(0.1)
    //                                .offset(y: -fontSize / 1.2)
    //                        }

}

struct HuriganaTestView_Previews: PreviewProvider {
    static var previews: some View {
        HuriganaText(HuriganaConverter.shared.convert("弟さん全然大丈夫ですよ"))
            .padding(50)
    }
}
