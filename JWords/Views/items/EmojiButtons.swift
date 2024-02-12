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
    
    private let buttonColors = [
        Color.red.opacity(0.5),
        Color.blue.opacity(0.5),
        Color.green.opacity(0.5)
    ]
    
    init(
        buttons: [(emoji: String, action: () -> Void)],
        buttonSize: CGSize = .init(width: 30, height: 30),
        buttonGap: CGFloat = .init(10)
    ) {
        self.buttons = buttons
        self.buttonSize = buttonSize
        self.buttonGap = buttonGap
        let totalLengthOfButtons = buttonSize.height * CGFloat(buttons.count) + buttonGap * CGFloat(buttons.count - 1)
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
        Button("▶️") {
            showButtons.toggle()
        }
        .frame(width: buttonSize.width, height: buttonSize.height)
        .rotationEffect(showButtons ? .degrees(180) : .degrees(0))
        .animation(.easeIn(duration: 0.3), value: showButtons)
    }
    
    private var emojiButtons: some View {
        let offSetCoefficient = buttonSize.height + buttonGap
        
        return ZStack {
            ForEach(0..<buttons.count, id: \.self) { idx in
                Button(action: {
                    buttons[idx].action()
                }, label: {
                    ZStack {
                        Circle()
                            .fill(buttonColors[idx % buttonColors.count])
                            .frame(width: buttonSize.width + 5, height: buttonSize.height + 5)
                        Text(buttons[idx].emoji)
                    }
                })
                .frame(width: buttonSize.width, height: buttonSize.height)
                .offset(
                    x: showButtons ? -buttonSize.width : 0,
                    y: showButtons ? (offSetStart + CGFloat(idx) * offSetCoefficient) : 0
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
