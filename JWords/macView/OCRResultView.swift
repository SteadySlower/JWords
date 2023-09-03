//
//  OCRResultView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import SwiftUI
import Vision

struct OCRResultView: View {
    let image: InputImageType
    let koreanResults: [OCRResult]
    let japaneseResults: [OCRResult]
    
    var body: some View {
        GeometryReader { geometry in
            imageView
                .resizable()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    ForEach(koreanResults) { result in
                        let pixelRect = convert(boundingBox: result.position, to: geometry.frame(in: .local))
                        Rectangle()
                            .fill(Color.blue.opacity(0.5))
                            .frame(width: pixelRect.width,
                                   height: pixelRect.height)
                            .position(x: pixelRect.midX, y: pixelRect.midY)
                    }
                )
                .overlay(
                    ForEach(japaneseResults) { result in
                        let pixelRect = convert(boundingBox: result.position, to: geometry.frame(in: .local))
                        Rectangle()
                            .fill(Color.red.opacity(0.5))
                            .frame(width: pixelRect.width,
                                   height: pixelRect.height)
                            .position(x: pixelRect.midX, y: pixelRect.midY)
                    }
                )
        }
        .border(Color.black)
    }
    
    private var imageView: Image {
        #if os(iOS)
        Image(uiImage: image)
        #elseif os(macOS)
        Image(nsImage: image)
        #endif
    }
    
}

fileprivate func convert(boundingBox: CGRect, to bounds: CGRect) -> CGRect {

    let imageWidth = bounds.width
    let imageHeight = bounds.height

    // Begin with input rect.
    var rect = boundingBox

    // Reposition origin.
    rect.origin.x *= imageWidth
    rect.origin.x += bounds.minX
    rect.origin.y = (1 - rect.maxY) * imageHeight + bounds.minY

    // Rescale normalized coordinates.
    rect.size.width *= imageWidth
    rect.size.height *= imageHeight

    return rect
}
