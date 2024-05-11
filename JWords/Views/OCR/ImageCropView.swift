//
//  ImageCropView.swift
//  JWords
//
//  Created by JW Moon on 5/6/24.
//

import SwiftUI
import PencilKit
import Model

struct ImageCropView: View {
    let image: InputImageType
    let onImageCropped: (InputImageType) -> Void
    
    @State var start: CGPoint = .zero
    @State var end: CGPoint = .zero
    @State var cropGuide: CGRect?
    
    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Image(uiImage: image)
                    .resizable()
                OCRCanvasView(start: $start, end: $end, cropGuide: $cropGuide)
                Rectangle()
                    .fill(.green.opacity(0.3))
                    .position(
                        x: (start.x + end.x) / 2,
                        y: (start.y + end.y) / 2
                    )
                    .frame(
                        width: abs(end.x - start.x),
                        height: abs(end.y - start.y),
                        alignment: .topLeading
                    )
            }
            .frame(width: image.size.width, height: image.size.height)
        }
        .onChange(of: cropGuide, {
            if let cropGuide = cropGuide,
               let croppedImage = cropImage(image, toRect: cropGuide, viewWidth: image.size.width, viewHeight: image.size.height) {
                onImageCropped(croppedImage)
            }
        })
    }
}

func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
{
//    let imageViewScale = max(inputImage.size.width / viewWidth,
//                             inputImage.size.height / viewHeight)
    
    let xScale = inputImage.size.width / viewWidth
    let yScale = inputImage.size.height / viewHeight


    // Scale cropRect to handle images larger than shown-on-screen size
    let cropZone = CGRect(x:cropRect.origin.x * xScale,
                          y:cropRect.origin.y * yScale,
                          width:cropRect.size.width * xScale,
                          height:cropRect.size.height * yScale)


    // Perform cropping in Core Graphics
    guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
    else {
        return nil
    }

    return UIImage(cgImage: cutImageRef)
}

struct OCRCanvasView {
    init(start: Binding<CGPoint>, end: Binding<CGPoint>, cropGuide: Binding<CGRect?>) {
        self.canvasView = OCRPKCanvas(start: start, end: end, cropGuide: cropGuide)
    }
    
    @State var canvasView: OCRPKCanvas

}

extension OCRCanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> OCRPKCanvas {
        return canvasView
    }

    func updateUIView(_ uiView: OCRPKCanvas, context: Context) {}
}

class OCRPKCanvas: PKCanvasView {
    
    @Binding var start: CGPoint
    @Binding var end: CGPoint
    @Binding var cropGuide: CGRect?
    
    init(start: Binding<CGPoint>, end: Binding<CGPoint>, cropGuide: Binding<CGRect?>) {
        self._start = start
        self._end = end
        self._cropGuide = cropGuide
        super.init(frame: .zero)
        self.tool = PKInkingTool(.pen, color: .clear, width: 5)
        self.backgroundColor = .clear
        self.drawingPolicy = .pencilOnly
        #if targetEnvironment(simulator)
        self.drawingPolicy = .anyInput
        #endif
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            start = touch.location(in: self)
            end = start
            cropGuide = nil
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            end = touch.location(in: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touches.forEach { touch in
            end = touch.location(in: self)
            cropGuide = .init(
                x: start.x,
                y: start.y,
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
        }
    }

}


#Preview {
    ImageCropView(
        image: UIImage(named: "Study View 1")!,
        onImageCropped: { _ in }
    )
}
