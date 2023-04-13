//
//  WordAddField.swift
//  JWords
//
//  Created by JW Moon on 2023/04/01.
//

import SwiftUI

struct WordAddField: View {
    
    private let title: String
    @Binding private var text: String
    
    init(title: String, text: Binding<String>)
    {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 20))
            TextEditor(text: $text)
                .font(.system(size: 30))
                .frame(height: Constants.Size.deviceHeight / 8)
                .padding(.horizontal)
        }
    }
}
