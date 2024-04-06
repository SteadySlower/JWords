//
//  LoadingView.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

public extension View {
    func loadingView(_ isLoading: Bool) -> some View {
        modifier(LoadingView(isLoading: isLoading))
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
