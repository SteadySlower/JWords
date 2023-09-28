//
//  KeyBoardDismissingBackground.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import SwiftUI

extension View {
    func dismissKeyboardWhenBackgroundTapped() -> some View {
        modifier(KeyBoardDismissingBackGround())
    }
}

private func dismissKeyBoard() {
    #if os(iOS)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}

private struct KeyBoardDismissingBackGround: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.white
                .onTapGesture { dismissKeyBoard() }
            content
        }
    }
}
