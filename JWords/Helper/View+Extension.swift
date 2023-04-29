//
//  View+Extension.swift
//  JWords
//
//  Created by JW Moon on 2023/02/18.
//

import SwiftUI

// MARK: SideBar

private struct SideBar<Content: View>: View {
    
    @Binding private var showSideBar: Bool
    @GestureState private var dragAmount: CGSize = .zero
    @ViewBuilder private var content: () -> Content
    
    init(showSideBar: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content) {
        self._showSideBar = showSideBar
        self.content = content
    }
    
    var body: some View {
        if showSideBar {
            ZStack(alignment: .trailing) {
                Color.black.opacity(0.5)
                    .onTapGesture { showSideBar = false }
                content()
                    .frame(width: Constants.Size.deviceWidth * 0.7)
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
        if value.translation.width > Constants.Size.deviceWidth * 0.35 {
            showSideBar = false
        }
    }
}

extension View {
    
    func sideBar<Content: View>(
        showSideBar: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content) -> some View {
        
        ZStack {
            self
            SideBar(showSideBar: showSideBar, content: content)
        }
    }

}

// MARK: Hide

extension View {
    @ViewBuilder func hide(_ bool: Bool) -> some View {
        if bool {
            EmptyView()
        } else {
            self
        }
    }
}

// MARK: Synchronize
// use to synchronize view's FocusState and the store's state

extension View {
  func synchronize<Value>(
    _ first: Binding<Value>,
    _ second: FocusState<Value>.Binding
  ) -> some View {
    self
      .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
      .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
  }
}
