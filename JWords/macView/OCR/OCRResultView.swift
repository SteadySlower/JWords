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
    let ocrTapped: (OCRLang, String) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            imageView
                .resizable()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .overlay(
                    ForEach(koreanResults) { result in
                        let pixelRect = convert(boundingBox: result.position, to: geometry.frame(in: .local))
                        let buttonPosition = CGPoint(
                            x: pixelRect.minX,
                            y: pixelRect.midY
                        )
                        copyButton(lang: .korean, result: result)
                            .position(buttonPosition)
                    }
                )
                .overlay(
                    ForEach(japaneseResults) { result in
                        let pixelRect = convert(boundingBox: result.position, to: geometry.frame(in: .local))
                        let buttonPosition = CGPoint(
                            x: pixelRect.maxX,
                            y: pixelRect.midY
                        )
                        copyButton(lang: .japanese, result: result)
                            .position(buttonPosition)
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
    
    private func copyButton(lang: OCRLang, result: OCRResult) -> some View {
        let size: CGFloat = 20
        let color = lang == .korean ? Color.blue.opacity(0.5) : Color.red.opacity(0.5)

        
        return Button {
            ocrTapped(lang, result.string)
        } label: {
            ZStack {
                Circle()
                    .fill(color)
                Text(lang == .korean ? "韓" : "日")
                    .font(.system(size: size))
            }
            .frame(width: size, height: size)
        }
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
