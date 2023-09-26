//
//  InputFieldButton.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import SwiftUI

struct InputFieldButton: View {
    
    let label: String
    let onTapped: () -> Void
    
    var body: some View {
        Button {
            onTapped()
        } label: {
            Text(label)
                .font(.system(size: Constants.Size.UNIT_INPUT_FONT - 15))
                .foregroundColor(.black)
                .padding(5)
                .defaultRectangleBackground()
        }
    }
}

#Preview {
    InputFieldButton(
        label: "입력",
        onTapped: {}
    )
}
