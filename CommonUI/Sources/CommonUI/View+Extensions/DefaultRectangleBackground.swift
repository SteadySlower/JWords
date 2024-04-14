//
//  DefaultRectangleBackground.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

public extension View {
    func defaultRectangleBackground() -> some View {
        modifier(DefaultRectangleBackground())
    }
}

private struct DefaultRectangleBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 5, y: 5)
            )
    }
}
