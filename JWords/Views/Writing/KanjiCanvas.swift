//
//  KanjiCanvas.swift
//  JWords
//
//  Created by Jong Won Moon on 1/8/24.
//

import SwiftUI
import PencilKit

struct KanjiCanvas: View {
    @State private var canvasView = PKCanvasView()
    
    var body: some View {
        CanvasView(canvasView: $canvasView)
    }
}

#Preview {
    KanjiCanvas()
}

struct CanvasView {
    @Binding var canvasView: PKCanvasView
}

extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
