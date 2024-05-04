//
//  DismissKeyboard.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

public extension View {
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
