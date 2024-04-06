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
