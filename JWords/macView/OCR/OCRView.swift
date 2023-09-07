//
//  OCRView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import SwiftUI
import ComposableArchitecture

struct OCR: ReducerProtocol {
    struct State: Equatable {
        var image: InputImageType
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
        
        init(_ image: InputImageType) {
            self.image = image
        }
    }
    
    enum Action: Equatable {
        case ocrMarkTapped(OCRLang, String)
        case removeImageButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            GeometryReader { geometry in
                ZStack(alignment: .topTrailing) {
                    imageView(vs.image)
                        .overlay(
                            copyButtons(lang: .korean,
                                        results: vs.koreanOcrResult,
                                        in: geometry.frame(in: .local)) {
                                            vs.send(.ocrMarkTapped($0, $1))
                                        }
                        )
                        .overlay(
                            copyButtons(lang: .japanese,
                                        results: vs.japaneseOcrResult,
                                        in: geometry.frame(in: .local)) {
                                            vs.send(.ocrMarkTapped($0, $1))
                                        }
                        )
                    xButton { vs.send(.removeImageButtonTapped) }
                }
            }
        }
    }
}

// MARK: SubView

extension OCRView {
    
    private func imageView(_ image: InputImageType) -> Image {
        #if os(iOS)
        Image(uiImage: image)
        #elseif os(macOS)
        Image(nsImage: image)
        #endif
    }
    
    private func copyButtons(lang: OCRLang,
                        results: [OCRResult],
                        in bounds: CGRect,
                        onTapped: @escaping (OCRLang, String) -> Void
    ) -> some View {
        ForEach(results, id: \.id) { result in
            let pixelRect = convert(boundingBox: result.position, to: bounds)
            let buttonPosition = CGPoint(
                x: lang == .korean ? pixelRect.minX : pixelRect.maxX,
                y: lang == .korean ? pixelRect.minY : pixelRect.maxY
            )
            copyButton(lang: lang) {
                onTapped(lang, result.string)
            }
            .position(buttonPosition)
        }
    }
    
    private func copyButton(lang: OCRLang, _ onTapped: @escaping () -> Void) -> some View {
        let size: CGFloat = 10
        let color = lang == .korean ? Color.blue.opacity(0.5) : Color.red.opacity(0.5)

        return Button {
            onTapped()
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
    
    private func xButton(_ onTapped: @escaping () -> Void) -> some View {
        Button {
            onTapped()
        } label: {
            Image(systemName: "x.circle.fill")
                .foregroundColor(.red)
                .frame(width: 25, height: 25)
        }
    }
    
}

// MARK: Helper functions

extension OCRView {
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
}
