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
        var ocr: GetWordsFromOCR.State?
    }
    
    enum Action: Equatable {
        case getImage(GetImageForOCR.Action)
        case ocr(GetWordsFromOCR.Action)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case koreanOCR(String)
        case japaneseOCR(String)
    }
    
    private let ocrClient: OCRClient = .shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImage(let action):
                switch action {
                case .imageFetched(let image):
                    state.ocr = GetWordsFromOCR.State(image: image)
                    return .merge(
                        .task {
                            await .koreanOcrResponse(TaskResult {
                                try await OCRClient.shared.ocr(from: image, lang: .korean)
                            })
                        },
                        .task {
                            await .japaneseOcrResponse(TaskResult {
                                try await OCRClient.shared.ocr(from: image, lang: .japanese)
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
                default: return .none
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
            GetWordsFromOCR()
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
