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
        var image: InputImageType
    }
    
    enum Action: Equatable {
        case imageCropped(InputImageType)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case koreanCropped(String)
        case japaneseCropped(String)
    }
    
    @Dependency(OCRClient.self) var ocrClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
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
                if let korean = result.first?.string {
                    return .send(.koreanCropped(korean))
                }
            case .japaneseOcrResponse(.success(let result)):
                if let japanese = result.first?.string {
                    return .send(.japaneseCropped(japanese))
                }
            default: break
            }
            return .none
        }
    }
}

struct CropOCRView: View {
    
    let store: StoreOf<OCRwithCroppedImage>
    
    var body: some View {
        ImageCropView(
            image: store.image,
            onImageCropped: { store.send(.imageCropped($0)) }
        )
    }
    
}

#Preview {
    CropOCRView(store: Store(
        initialState: OCRwithCroppedImage.State(image: UIImage(named: "Study View 1")!),
        reducer: { OCRwithCroppedImage() })
    )
}

