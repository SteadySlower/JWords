//
//  Alignment.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

public extension View {
    func leadingAlignment() -> some View {
        modifier(LeadingAligner())
    }
    
    func trailingAlignment() -> some View {
        modifier(TrailingAligner())
    }
}

private struct LeadingAligner: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

private struct TrailingAligner: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            Spacer()
            content
        }
    }
}

