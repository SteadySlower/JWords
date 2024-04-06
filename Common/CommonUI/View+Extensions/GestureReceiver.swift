//
//  GestureReceiver.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

// GestureReceiver

public extension View {
    func addCellGesture(isLocked: Bool, gestureHanlder: @escaping (CellGesture) -> Void) -> some View {
        ModifiedContent(content: self, modifier: GestureReceiver(isLocked: isLocked, gestureHanlder: gestureHanlder))
    }
}

public enum CellGesture {
    case tapped
    case doubleTapped
    case dragging(CGSize)
    case draggedLeft
    case draggedRight
}

private struct GestureReceiver: ViewModifier {
    
    let isLocked: Bool
    let gestureHanlder: (CellGesture) -> Void
    
    // gestures
    let dragGesture = DragGesture(minimumDistance: 30, coordinateSpace: .global)
    let tapGesture = TapGesture()
    let doubleTapGesture = TapGesture(count: 2)
    
    func body(content: Content) -> some View {
        content
            .gesture(dragGesture
                .onChanged { if isLocked { return }; gestureHanlder(.dragging($0.translation)) }
                .onEnded { gestureHanlder($0.translation.width > 0 ? .draggedLeft : .draggedRight) }
            )
            .gesture(doubleTapGesture.onEnded { gestureHanlder(.doubleTapped) })
            .gesture(tapGesture.onEnded { gestureHanlder(.tapped) })
    }
    
}
