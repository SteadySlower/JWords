//
//  InputButtonStyle.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

private let UNIT_INPUT_FONT: CGFloat = 30

public struct InputButtonStyle: ButtonStyle {
    
    private let isAble: Bool
    
    public init(isAble: Bool = true) {
        self.isAble = isAble
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: UNIT_INPUT_FONT - 15))
            .foregroundColor(isAble ? .black : .gray)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .defaultRectangleBackground()
    }
}
