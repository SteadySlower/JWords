//
//  OCRView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct GetTextsFromOCR {
    @ObservableState
    struct State: Equatable {
        var image: InputImageType
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
    }
    
    enum Action: Equatable {
        case ocrMarkTapped(OCRLang, String)
        case removeImageButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

struct OCRResultView: View {
    
    let store: StoreOf<GetTextsFromOCR>
    
    var body: some View {
        VStack {
            title
            buttonGuide
            GeometryReader { proxy in
                imageView(store.image)
                    .overlay(
                        copyButtons(lang: .korean,
                                    results: store.koreanOcrResult,
                                    in: proxy.frame(in: .local)) {
                                        store.send(.ocrMarkTapped($0, $1))
                                    }
                    )
                    .overlay(
                        copyButtons(lang: .japanese,
                                    results: store.japaneseOcrResult,
                                    in: proxy.frame(in: .local)) {
                                        store.send(.ocrMarkTapped($0, $1))
                                    }
                    )
            }
            .frame(width: store.image.size.width, height: store.image.size.height)
            xButton { store.send(.removeImageButtonTapped) }
                .padding(.horizontal, 20)
        }
    }
}

// MARK: SubView

extension OCRResultView {
    
    private var title: some View {
        Text("스캔 결과")
            .font(.system(size: 20))
            .bold()
            .leadingAlignment()
            .padding(.leading, 10)
    }
    
    private var buttonGuide: some View {
        HStack {
            Spacer()
            Text("↘️ 한국어 스캔")
            Spacer()
            Text("↖️ 일본어 스캔")
            Spacer()
        }
    }
    
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
        return Button {
            onTapped()
        } label: {
            Text(lang == .korean ? "↘️" : "↖️")
                .font(.system(size: 10))
        }
    }
    
    private func xButton(_ onTapped: @escaping () -> Void) -> some View {
        RectangleButton(
            image: Image(systemName: "photo.on.rectangle.angled"),
            title: "다른 이미지 스캔하기",
            isVertical: false,
            onTapped: onTapped)
    }
    
}

// MARK: Helper functions

extension OCRResultView {
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
