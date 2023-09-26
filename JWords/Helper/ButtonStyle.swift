//
//  ButtonStyle.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import SwiftUI

struct InputFieldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Constants.Size.UNIT_INPUT_FONT - 15))
            .foregroundColor(.black)
            .padding(5)
            .defaultRectangleBackground()
    }
}

struct InputButtonStyle: ButtonStyle {
    
    private let isAble: Bool
    
    init(isAble: Bool = true) {
        self.isAble = isAble
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: Constants.Size.UNIT_INPUT_FONT - 15))
            .foregroundColor(isAble ? .black : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .defaultRectangleBackground()
    }
}
