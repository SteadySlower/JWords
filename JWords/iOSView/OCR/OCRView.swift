//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct OCR: ReducerProtocol {
    
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
    
    @Dependency(\.ocrClient) var ocrClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImage(let action):
                switch action {
                case .imageFetched(let image):
                    state.ocr = GetTextsFromOCR.State(image: image)
                    return .merge(
                        .task {
                            await .koreanOcrResponse(TaskResult {
                                try await ocrClient.ocr(image, .korean)
                            })
                        },
                        .task {
                            await .japaneseOcrResponse(TaskResult {
                                try await ocrClient.ocr(image, .japanese)
                            })
                        }
                    )
                default:
                    return .none
                }
            case .ocr(let action):
                switch action {
                case .ocrMarkTapped(let lang, let text):
                    if lang == .korean {
                        return .task { .koreanOCR(text) }
                    } else {
                        return .task { .japaneseOCR(text) }
                    }
                case .removeImageButtonTapped:
                    state.ocr = nil
                    return .none
                }
            case .japaneseOcrResponse(.success(let result)):
                state.ocr?.japaneseOcrResult = result
                return .none
            case .koreanOcrResponse(.success(let result)):
                state.ocr?.koreanOcrResult = result
                return .none
            default: return .none
            }
        }
        .ifLet(\.ocr, action: /Action.ocr) {
            GetTextsFromOCR()
        }
        Scope(state: \.getImage, action: /Action.getImage) {
            GetImageForOCR()
        }
    }
    
}

struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            if vs.ocr == nil {
                GetImageForOCRView(store: store.scope(
                    state: \.getImage,
                    action: OCR.Action.getImage)
                )
            } else {
                IfLetStore(store.scope(
                    state: \.ocr,
                    action: OCR.Action.ocr)
                ) {
                    OCRResultView(store: $0)
                }
            }
        }
    }
}
