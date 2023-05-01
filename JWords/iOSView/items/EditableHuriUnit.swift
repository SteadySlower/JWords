//
//  EditableHuriView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct EditableHuriUnit: View {
    
    let huri: Huri
    let fontSize: CGFloat
    let onHuriUpdated: (Huri) -> Void
    
    @State var showAlert: Bool = false
    @State var text: String = ""
    
    var body: some View {
        Group {
            if !huri.kanji.isEmpty {
                ZStack {
                    Text(huri.kanji)
                        .font(.system(size: fontSize))
                    Button(huri.gana) {
                        showAlert = true
                    }
                    .font(.system(size: fontSize / 2))
                    .lineLimit(1)
                    .offset(y: -fontSize / 1.2)
                }
            } else {
                Text(huri.gana)
                    .font(.system(size: fontSize))
            }
        }
        .alert("후리가나 수정", isPresented: $showAlert) {
            TextField(huri.gana, text: $text)
            Button("수정") {
                if text.isEmpty { showAlert = false; return }
                let newHuri = Huri(id: huri.id, kanji: huri.kanji, gana: text)
                onHuriUpdated(newHuri)
            }
            Button("취소", role: .cancel) { text = "" }
        } message: {
            Text("\(huri.kanji)의 읽는 법을 수정합니다.")
        }

    }
}
