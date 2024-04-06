//
//  SpeechBubble.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

public extension View {
    func speechBubble(direction: SpeechBubbleStyle.Direction = .topLeft,
                      maxWidth: CGFloat = .infinity,
                      color: Color = .yellow.opacity(0.5),
                      alignment: Alignment = .leading) -> some View {
        ModifiedContent(content: self, modifier: SpeechBubbleStyle(direction: direction, maxWidth: maxWidth, color: color, alignment: alignment) )
    }
}

public struct SpeechBubbleStyle: ViewModifier {
    
    public enum Direction {
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

    public func body(content: Content) -> some View {
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
