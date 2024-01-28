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
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pencil, color: .black, width: 5)
        canvasView.delegate = context.coordinator
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
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
            didDraw = true
        }
    }
}
