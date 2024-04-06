//
//  SlidableCell.swift
//  JWords
//
//  Created by JW Moon on 1/29/24.
//

import SwiftUI
import Model
import CommonUI

struct SlidableCell<V: View>: View {
    
    private let studyState: StudyState
    private let dragAmount: CGSize
    private let content: () -> V
    
    init(
         studyState: StudyState,
         dragAmount: CGSize = .zero,
         content: @escaping () -> V
    ) {
        self.studyState = studyState
        self.dragAmount = dragAmount
        self.content = content
    }

    var body: some View {
        ZStack {
            if dragAmount == .zero {
                cellColor(studyState)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                cellColor(dragAmount)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            content()
        }
        .defaultRectangleBackground()
        .offset(dragAmount)
    }
}

extension SlidableCell {
    
    private func cellColor(_ studyState: StudyState) -> Color {
        switch studyState {
        case .undefined:
            return Color.white
        case .success:
            return Color(red: 207/256, green: 240/256, blue: 204/256)
        case .fail:
            return Color(red: 253/256, green: 253/256, blue: 150/256)
        }
    }
    
    private func cellColor(_ dragAmount: CGSize) -> Color {
        let opacity = (abs(dragAmount.width) * abs(dragAmount.width)) / (150 * 150)
        
        if dragAmount.width > 0 {
            return Color(red: 207/256, green: 240/256, blue: 204/256).opacity(opacity)
        } else {
            return Color(red: 253/256, green: 253/256, blue: 150/256).opacity(opacity)
        }
    }
    
}

#Preview {
    SlidableCell(
        studyState: .success,
        dragAmount: .zero,
        content: { Text("Hello World!") }
    )
}
