//
//  WordAddField.swift
//  JWords
//
//  Created by JW Moon on 2023/04/01.
//

import SwiftUI

struct WordAddField: View {
    
    private let inputType: InputType
    private let onTextChange: (InputType, String) -> Void
    
    init(inputType: InputType,
         onTextChange: @escaping (InputType, String) -> Void)
    {
        self.inputType = inputType
        self.onTextChange = onTextChange
    }
    
    @State private var text: String = ""
    
    var body: some View {
        VStack {
            Text("\(inputType.description) 입력")
                .font(.system(size: 20))
            TextEditor(text: $text)
                .font(.system(size: 30))
                .frame(height: Constants.Size.deviceHeight / 8)
                .padding(.horizontal)
        }
        .onChange(of: text) { onTextChange(inputType, $0) }
    }
}
