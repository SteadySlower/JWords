//
//  EmojiButtons.swift
//  JWords
//
//  Created by JW Moon on 2/12/24.
//

import SwiftUI

struct EmojiButtons: View {
    
    private let buttons: [(emoji: String, action: () -> Void)]
    private let buttonSize: CGSize
    private let buttonGap: CGFloat
    private let offSetStart: CGFloat
    
    init(
        buttons: [(emoji: String, action: () -> Void)],
        buttonSize: CGSize = .init(width: 30, height: 30),
        buttonGap: CGFloat = .init(10)
    ) {
        self.buttons = buttons
        self.buttonSize = buttonSize
        self.buttonGap = buttonGap
        let totalLengthOfButtons = buttonSize.width * CGFloat(buttons.count) + buttonGap * CGFloat(buttons.count - 1)
        self.offSetStart = -((totalLengthOfButtons / 2) - buttonSize.width / 2)
    }
    
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
            toggleButton
            emojiButtons
        }
    }
}

extension EmojiButtons {
    private var toggleButton: some View {
        Button("🔼") {
            showButtons.toggle()
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .rotationEffect(showButtons ? .degrees(180) : .degrees(0))
        .animation(.easeIn(duration: 0.3), value: showButtons)
    }
    
    private var emojiButtons: some View {
        let offSetCoefficient = buttonSize.width + buttonGap
        
        return ZStack {
            ForEach(0..<buttons.count, id: \.self) { idx in
                Button(buttons[idx].emoji) {
                    buttons[idx].action()
                }
                .frame(width: buttonSize.width, height: buttonSize.height)
                .offset(
                    x: showButtons ? (offSetStart + CGFloat(idx) * offSetCoefficient) : 0,
                    y: showButtons ? -buttonSize.height : 0
                )
                .opacity(showButtons ? 1 : 0)
                .animation(.easeIn(duration: 0.3), value: showButtons)
            }
        }
    }
}

#Preview {
    EmojiButtons(buttons: [
        (emoji: "✏️", action: { print("✏️") }),
        (emoji: "⭐️", action: { print("⭐️") }),
        (emoji: "✅", action: { print("✅") })
    ])
}
