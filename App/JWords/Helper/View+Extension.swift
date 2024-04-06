//
//  View+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/02/18.
//

import SwiftUI

// MARK: CornerRadius

#if os(iOS)

private struct CornerRadiusShape: Shape {
    var radius = CGFloat.infinity
    var corners = UIRectCorner.allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

private struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner

    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}

// MARK: Speech Bubble

struct SpeechBubbleStyle: ViewModifier {
    
    enum Direction {
        case topLeft, bottomLeft
        
        var corners: UIRectCorner {
            switch self {
            case .topLeft: return [.bottomLeft, .topRight, .bottomRight]
            case .bottomLeft: return [.topLeft, .topRight, .bottomRight]
            }
        }
    }
    
    private let direction: Direction
    private let maxWidth: CGFloat
    private let color: Color
    private let alignment: Alignment
    
    init(direction: Direction,
         maxWidth: CGFloat,
         color: Color,
         alignment: Alignment) {
        self.direction = direction
        self.maxWidth = maxWidth
        self.color = color
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Rectangle()
                    .fill(color)
                    .cornerRadius(radius: 24, corners: direction.corners)
            }
            .frame(maxWidth: maxWidth,
                   alignment: alignment)
    }
}

extension View {
    func speechBubble(direction: SpeechBubbleStyle.Direction = .topLeft,
                      maxWidth: CGFloat = .infinity,
                      color: Color = .yellow.opacity(0.5),
                      alignment: Alignment = .leading) -> some View {
        ModifiedContent(content: self, modifier: SpeechBubbleStyle(direction: direction, maxWidth: maxWidth, color: color, alignment: alignment) )
    }
}

#endif

// GestureReceiver

extension View {
    func addCellGesture(isLocked: Bool, gestureHanlder: @escaping (CellGesture) -> Void) -> some View {
        ModifiedContent(content: self, modifier: GestureReceiver(isLocked: isLocked, gestureHanlder: gestureHanlder))
    }
}

enum CellGesture {
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
