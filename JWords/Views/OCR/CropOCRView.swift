//
//  CropOCRView.swift
//  JWords
//
//  Created by JW Moon on 5/8/24.
//

import SwiftUI
import Model
import ComposableArchitecture
import OCRClient
import OCRKit

@Reducer
struct OCRwithCroppedImage {
    @ObservableState
    struct State: Equatable {
        var getImage = GetImageForOCR.State()
        var image: InputImageType?
        var koreanResult: String?
        var japaneseResult: String?
    }
    
    enum Action: Equatable {
        case getImage(GetImageForOCR.Action)
        case imageCropped(InputImageType)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
    }
    
    @Dependency(OCRClient.self) var ocrClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImage(.imageFetched(let image)):
                state.image = image
            case .imageCropped(let image):
                return .merge(
                    .run { send in
                        await send(.koreanOcrResponse(TaskResult { try await ocrClient.ocr(image, .korean)}))
                    },
                    .run { send in
                        await send(.japaneseOcrResponse(TaskResult {try await ocrClient.ocr(image, .japanese)}))
                    }
                )
            case .koreanOcrResponse(.success(let result)):
                state.koreanResult = result.first?.string
            case .japaneseOcrResponse(.success(let result)):
                state.japaneseResult = result.first?.string
            default: break
            }
            return .none
        }
        Scope(state: \.getImage, action: \.getImage) { GetImageForOCR() }
    }
}

struct CropOCRView: View {
    
    let store: StoreOf<OCRwithCroppedImage>
    
    var body: some View {
        VStack {
            if let image = store.image {
                ImageCropView(image: image) { store.send(.imageCropped($0)) }
            } else {
                GetImageForOCRView(store: store.scope(state: \.getImage, action: \.getImage))
            }
        }
    }
    
}

#Preview {
    CropOCRView(store: Store(
        initialState: OCRwithCroppedImage.State(),
        reducer: { OCRwithCroppedImage() })
    )
}

