//
//  iOSHuriganaTestView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI

struct iOSHuriganaTestView: View {
    
    @State var words = [String]()
    @State var text = ""
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(words, id: \.self) { word in
                        HuriganaCell(hurigana: word)
                    }
                }
            }
            TextField("", text: $text)
                .border(.black)
            Button("submit") {
                words.append(HuriganaConverter.shared.convert(text))
                text = ""
            }
        }
        .padding(10)
    }
}

struct HuriganaCell: View {
    
    let hurigana: String
    
    var body: some View {
        HuriganaText(hurigana: hurigana)
            .background { Color.green }
            .padding(.horizontal, 10)
    }
    
}

struct iOSHuriganaTestView_Previews: PreviewProvider {
    static var previews: some View {
        iOSHuriganaTestView()
    }
}
