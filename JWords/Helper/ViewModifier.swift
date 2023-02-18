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
        modifier(CellSelectionEdge(nowSelecting: nowSelecting,
                                isSelected: isSelected,
                                selectedColor: selectedColor,
                                unselectedColor: unselectedColor,
                                onTap: onTap))
    }
    
}

private struct CellSelectionEdge: ViewModifier {
    
    private let nowSelecting: Bool
    private let isSelected: Bool
    private let selectedColor: Color
    private let unselectedColor: Color
    private let onTap: () -> Void
    
    @State private var dashPhase: CGFloat = 0
    
    init(nowSelecting: Bool, isSelected: Bool, selectedColor: Color, unselectedColor: Color, onTap: @escaping () -> Void) {
        self.nowSelecting = nowSelecting
        self.isSelected = isSelected
        self.selectedColor = selectedColor
        self.unselectedColor = unselectedColor
        self.onTap = onTap
    }
    
    func body(content: Content) -> some View {
        if nowSelecting {
            content
                .overlay {
                    if isSelected {
                        selectedOverlay
                    } else {
                        unselectedOverlay
                    }
                }
                .onTapGesture { onTap() }
        } else {
            content
        }
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
