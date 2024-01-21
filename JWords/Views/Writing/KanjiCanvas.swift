//
//  KanjiCanvas.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import PencilKit
import ComposableArchitecture

struct DrawWithPencil: Reducer {
    
    struct State: Equatable {
        var canvas: PKCanvasView
    }
    
    enum Action: Equatable {
        case toggleShowAnswer
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
    
}

struct KanjiCanvas: View {
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        ZStack {
            CanvasView(canvasView: $canvasView)
            resetButton
                .padding([.trailing, .bottom], 20)
        }
    }
}

extension KanjiCanvas {
    var resetButton: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    canvasView.drawing = PKDrawing()
                }, label: {
                    Image(systemName: "eraser")
                        .resizable()
                        .frame(width: 50, height: 50)
                })
            }
        }
    }
}

#Preview {
    KanjiCanvas()
}

struct CanvasView {
    @Binding var canvasView: PKCanvasView
}

extension CanvasView: UIViewRepresentable {
    // TODO: 이거 PKCanvasView를 안에 가지고 있게 하지 말고
        // https://ios-development.tistory.com/1043
        // -> 이거 참고해서 안에 PKCanvasView를 view 안에 넣고
        // 안에 didWrite: Bool 하나 만들고
        // https://developer.apple.com/documentation/pencilkit/pkcanvasviewdelegate
        // -> 이거 참고해서 delegate로 didDraw 이런거 되면 didWrite true로 돌리고
        // updateUIView에 didWrite false되면 PKCanvasView 리셋되도록 한다
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pencil, color: .black, width: 5)
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
