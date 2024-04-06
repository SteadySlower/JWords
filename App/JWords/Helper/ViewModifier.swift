//
//  ViewModifier.swift
//  JWords
//
//  Created by JW Moon on 2023/02/18.
//

import SwiftUI

extension View {
    
    func selectable(nowSelecting: Bool,
                    isSelected: Bool,
                    selectedColor: Color = Color.blue.opacity(0.2),
                    unselectedColor: Color = Color.gray.opacity(0.2),
                    onTap: @escaping () -> Void) -> some View {
        nowSelecting ? AnyView(modifier(CellSelectionEdge(isSelected: isSelected,
                                    selectedColor: selectedColor,
                                    unselectedColor: unselectedColor,
                                    onTap: onTap))) : AnyView(self)
    }
    
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

private struct CellSelectionEdge: ViewModifier {
    
    private let isSelected: Bool
    private let selectedColor: Color
    private let unselectedColor: Color
    private let onTap: () -> Void
    
    @State private var dashPhase: CGFloat = 0
    
    init(isSelected: Bool, selectedColor: Color, unselectedColor: Color, onTap: @escaping () -> Void) {
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.onTap = onTap
    }
    
    func body(content: Content) -> some View {
        content
            .overlay { isSelected ? AnyView(selectedOverlay) : AnyView(unselectedOverlay) }
            .onTapGesture { onTap() }
    }
    
    private var selectedOverlay: some View {
        selectedColor
            .mask(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10, 10], dashPhase: dashPhase))
                    .animation(.linear.repeatForever(autoreverses: false).speed(1), value: dashPhase)
                    .onAppear { dashPhase = -20 }
            )
    }
    
    private var unselectedOverlay: some View {
        unselectedColor
            .mask (
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [10, 10], dashPhase: dashPhase))
            )
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
