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
        case onJapaneseCropped(InputImageType)
        case onKoreanCropped(InputImageType)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case koreanOCRResult(String)
        case japaneseOCRResult(String)
    }
    
    @Dependency(OCRClient.self) var ocrClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onJapaneseCropped(let image):
                return .run { send in
                    await send(.japaneseOcrResponse(TaskResult {try await ocrClient.ocr(image, .japanese)}))
                }
            case .onKoreanCropped(let image):
                return .run { send in
                    await send(.koreanOcrResponse(TaskResult { try await ocrClient.ocr(image, .korean)}))
                }
            case .koreanOcrResponse(.success(let result)):
                if let korean = result.first?.string {
                    return .send(.koreanOCRResult(korean))
                }
            case .japaneseOcrResponse(.success(let result)):
                if let japanese = result.first?.string {
                    return .send(.japaneseOCRResult(japanese))
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
        VStack {
            Text("manaul_scan_direction")
                .lineLimit(nil)
            ImageCropView(
                image: store.image,
                onDownwardCropped: { store.send(.onJapaneseCropped($0)) },
                onUpwardCropped: { store.send(.onKoreanCropped($0)) }
            )
        }
    }
    
}

#Preview {
    CropOCRView(store: Store(
        initialState: OCRwithCroppedImage.State(image: UIImage(named: "Study View 1")!),
        reducer: { OCRwithCroppedImage() })
    )
}

