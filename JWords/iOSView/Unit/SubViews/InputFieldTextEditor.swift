//
//  InputFieldTextEditor.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import SwiftUI

struct InputFieldTextEditor: View {
    
    let text: Binding<String>
    
    var body: some View {
        TextEditor(text: text)
            .font(.system(size: Constants.Size.UNIT_INPUT_FONT))
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .defaultRectangleBackground()
    }
}

#Preview {
    @State var text: String = ""
    return InputFieldTextEditor(text: $text)
}