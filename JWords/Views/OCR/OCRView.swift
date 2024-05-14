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
import UtilClient

@Reducer
struct OCR {
    @ObservableState
    struct State: Equatable {
        var getImage = GetImageForOCR.State()
        var ocr: GetTextsFromOCR.State?
        var ocrWithCrop: OCRwithCroppedImage.State?
        var isAuto: Bool = true
        
        var isOCRAvailable: Bool {
            ocr != nil && ocrWithCrop != nil
        }
    }
    
    enum Action: Equatable {
        case getImage(GetImageForOCR.Action)
        case ocr(GetTextsFromOCR.Action)
        case ocrWithCrop(OCRwithCroppedImage.Action)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case koreanOCR(String)
        case japaneseOCR(String)
        case removeImage
        case changeToAuto
        case changeToManual
    }
    
    @Dependency(OCRClient.self) var ocrClient
    @Dependency(UtilClient.self) var utilClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImage(.imageFetched(let image)):
                state.ocrWithCrop = .init(image: image)
                let resized = utilClient.resizeImage(image, Constants.Size.deviceWidth)
                state.ocr = GetTextsFromOCR.State(image: resized!)
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
            case .ocrWithCrop(.japaneseOCRResult(let text)):
                return .send(.japaneseOCR(text))
            case .ocrWithCrop(.koreanOCRResult(let text)):
                return .send(.koreanOCR(text))
            case .japaneseOcrResponse(.success(let result)):
                state.ocr?.japaneseOcrResult = result
            case .koreanOcrResponse(.success(let result)):
                state.ocr?.koreanOcrResult = result
            case .removeImage:
                state.ocr = nil
                state.ocrWithCrop = nil
            case .changeToAuto:
                state.isAuto = true
            case .changeToManual:
                state.isAuto = false
            default: break
            }
            return .none
        }
        .ifLet(\.ocr, action: \.ocr) { GetTextsFromOCR() }
        .ifLet(\.ocrWithCrop, action: \.ocrWithCrop) { OCRwithCroppedImage() }
        Scope(state: \.getImage, action: \.getImage) { GetImageForOCR() }
    }
    
}

struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        if let ocrCropStore = store.scope(state: \.ocrWithCrop, action: \.ocrWithCrop), !store.isAuto {
            VStack {
                CropOCRView(store: ocrCropStore)
                autoScanButton { store.send(.changeToAuto) }
                RemoveImageButton { store.send(.removeImage) }
            }
        } else if let ocrResultStore = store.scope(state: \.ocr, action: \.ocr), store.isAuto {
            VStack {
                OCRResultView(store: ocrResultStore)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    manualScanButton { store.send(.changeToManual) }
                }
                RemoveImageButton { store.send(.removeImage) }
            }
        } else {
            GetImageForOCRView(store: store.scope(
                state: \.getImage,
                action: \.getImage)
            )
        }
    }
    
    private func manualScanButton(_ onTapped: @escaping () -> Void) -> some View {
        RectangleButton(
            image: Image(systemName: "highlighter"),
            title: "수동 스캔 모드",
            isVertical: false,
            onTapped: onTapped
        )
        .padding(.horizontal, 20)
    }
    
    private func autoScanButton(_ onTapped: @escaping () -> Void) -> some View {
        RectangleButton(
            image: Image(systemName: "autostartstop"),
            title: "자동 스캔 모드",
            isVertical: false,
            onTapped: onTapped
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    OCRView(store: Store(
        initialState: OCR.State(),
        reducer: { OCR() }
    ))
}
