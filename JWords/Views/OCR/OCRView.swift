//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI
import OCRKit
import OCRClient

@Reducer
struct OCR {
    @ObservableState
    struct State: Equatable {
        var getImage = GetImageForOCR.State()
        var ocr: GetTextsFromOCR.State?
    }
    
    enum Action: Equatable {
        case getImage(GetImageForOCR.Action)
        case ocr(GetTextsFromOCR.Action)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case koreanOCR(String)
        case japaneseOCR(String)
    }
    
    @Dependency(OCRClient.self) var ocrClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImage(.imageFetched(let image)):
                state.ocr = GetTextsFromOCR.State(image: image)
                return .merge(
                    .run { send in
                        await send(.koreanOcrResponse(TaskResult { try await ocrClient.ocr(image, .korean)}))
                    },
                    .run { send in
                        await send(.japaneseOcrResponse(TaskResult {try await ocrClient.ocr(image, .japanese)}))
                    }
                )
            case .ocr(.ocrMarkTapped(let lang, let text)):
                return lang == .korean ? .send(.koreanOCR(text)) : .send(.japaneseOCR(text))
            case .ocr(.removeImage):
                state.ocr = nil
            case .japaneseOcrResponse(.success(let result)):
                state.ocr?.japaneseOcrResult = result
            case .koreanOcrResponse(.success(let result)):
                state.ocr?.koreanOcrResult = result
            default: break
            }
            return .none
        }
        .ifLet(\.ocr, action: \.ocr) { GetTextsFromOCR() }
        Scope(state: \.getImage, action: \.getImage) { GetImageForOCR() }
    }
    
}

struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        if store.ocr == nil {
            GetImageForOCRView(store: store.scope(
                state: \.getImage,
                action: \.getImage)
            )
        } else {
            if let ocrResultStore = store.scope(state: \.ocr, action: \.ocr) {
                OCRResultView(store: ocrResultStore)
            }
        }
    }
}
