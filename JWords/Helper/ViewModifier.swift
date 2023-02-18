//
//  ViewModifier.swift
//  JWords
//
//  Created by JW Moon on 2023/02/18.
//

import SwiftUI

extension Color {
    
    func dashEdge(isAnimating: Bool) -> some View {
        modifier(DashEdge(isAnimating: isAnimating))
    }
    
}

private struct DashEdge: ViewModifier {
    
    let isAnimating: Bool
    @State private var dashPhase: CGFloat = 0
    
    func body(content: Content) -> some View {
        if isAnimating {
            content
                .mask(animatingEdge)
        } else {
            content
                .mask(nonAnimatingEdge)
        }
    }
    
    private var animatingEdge: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10, 10], dashPhase: dashPhase))
            .animation(.linear.repeatForever(autoreverses: false).speed(1), value: dashPhase)
            .onAppear { dashPhase = -20 }
    
    }
    
    private var nonAnimatingEdge: some View {
        Rectangle()
            .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10, 10], dashPhase: dashPhase))
    }
    
}
