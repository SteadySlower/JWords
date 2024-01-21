//
//  CanvasView.swift
//  JWords
//
//  Created by JW Moon on 1/21/24.
//

import SwiftUI
import PencilKit

struct CanvasView {
    @State var canvasView = PKCanvasView()
    @Binding var didDraw: Bool
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
        canvasView.delegate = context.coordinator
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        print("디버그 ", "update ui View")
        if !didDraw {
            canvasView.drawing = PKDrawing()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didDraw: $didDraw)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate {
        
        @Binding var didDraw: Bool
        
        init(didDraw: Binding<Bool>) {
            self._didDraw = didDraw
        }
        
        func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
            print("디버그 ", "canvas view did begin using tool")
            didDraw = true
        }
    }
}
