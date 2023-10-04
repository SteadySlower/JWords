//
//  InputSetTextField.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import SwiftUI

struct InputSetTextField: View {
    
    let placeHolder: String
    let text: Binding<String>
    
    var body: some View {
        TextField(placeHolder, text: text)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .font(.system(size: Constants.Size.SET_INPUT_FONT))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .defaultRectangleBackground()
    }
}

#Preview {
    @State var text: String = ""
    return InputSetTextField(
        placeHolder: "단어장 이름",
        text: $text
    )
}
