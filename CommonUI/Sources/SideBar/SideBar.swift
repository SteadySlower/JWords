//
//  SideBar.swift
//  CommonUI
//
//  Created by JW Moon on 4/6/24.
//

import SwiftUI

public extension View {
    func sideBar<Content: View>(
        deviceWidth: CGFloat,
        showSideBar: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        ZStack {
            self
            SideBar(
                deviceWidth: deviceWidth,
                showSideBar: showSideBar,
                content: content
            )
        }
    }
}

private struct SideBar<Content: View>: View {
    
    @Binding private var showSideBar: Bool
    @GestureState private var dragAmount: CGSize = .zero
    @ViewBuilder private var content: () -> Content
    
    private let deviceWidth: CGFloat
    
    init(
        deviceWidth: CGFloat,
        showSideBar: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.deviceWidth = deviceWidth
        self._showSideBar = showSideBar
        self.content = content
    }
    
    var body: some View {
        if showSideBar {
            ZStack(alignment: .trailing) {
                Color.black.opacity(0.5)
                    .onTapGesture { showSideBar = false }
                content()
                    .frame(width: deviceWidth * 0.7)
                    .background { Color.white }
                    .offset(x: dragAmount.width)
                    .gesture(dragGesture)
            }
            .ignoresSafeArea()
        } else {
            EmptyView()
        }
    }
    
    // gestures
    
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 30, coordinateSpace: .global)
            .onEnded { onEnded($0) }
            .updating($dragAmount) { value, state, _ in
                if value.translation.width > 0 {
                    state.width = value.translation.width
                }
            }
    }
    
    private func onEnded(_ value: DragGesture.Value) {
        if value.translation.width > deviceWidth * 0.35 {
            showSideBar = false
        }
    }
}
