//
//  InputFieldButtonStyle.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

private let UNIT_INPUT_FONT: CGFloat = 30

public struct InputFieldButtonStyle: ButtonStyle {
    
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: UNIT_INPUT_FONT - 15))
            .foregroundColor(.black)
            .padding(5)
            .defaultRectangleBackground()
    }
}


