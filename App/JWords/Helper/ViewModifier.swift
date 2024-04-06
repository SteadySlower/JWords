//
//  ViewModifier.swift
//  JWords
//
//  Created by JW Moon on 2023/02/18.
//

import SwiftUI

extension View {
    
    func loadingView(_ isLoading: Bool) -> some View {
        modifier(LoadingView(isLoading: isLoading))
    }
    
    func leadingAlignment() -> some View {
        modifier(LeadingAligner())
    }
    
    func trailingAlignment() -> some View {
        modifier(TrailingAligner())
    }
    
    func defaultRectangleBackground() -> some View {
        modifier(DefaultRectangleBackground())
    }
}



private struct LoadingView: ViewModifier {
    
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(5)
            }
            content
        }
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
