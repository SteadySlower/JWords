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
            TextField("", text: $text)
                .onChange(of: text) { hurigana = HuriganaConverter.shared.convert($0) }
        }
    }
}

struct HuriganaTestView_Previews: PreviewProvider {
    static var previews: some View {
        HuriganaTestView()
    }
}
