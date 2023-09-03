//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import SwiftUI
import ComposableArchitecture

struct OCR: ReducerProtocol {
    struct State: Equatable {
        var image: InputImageType?
        var ocrResult: [OCRResult] = []
    }
    
    enum Action: Equatable {
        case buttonTapped
        case imageTapped
        case imageFetched
        case ocrResponse(TaskResult<[OCRResult]>)
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                guard let fetchedImage = pasteBoardClient.fetchImage() else { return .none }
                state.image = fetchedImage
                return .task {
                    await .ocrResponse(TaskResult { try await OCRClient.shared.ocr(from: fetchedImage) })
                }
            case .imageTapped:
                state.image = nil
                state.ocrResult = []
                return .none
            case .ocrResponse(.success(let results)):
                state.ocrResult = results
                return .none
            default:
                return .none
            }
        }
    }

}


struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack {
                    if let image = vs.image {
                        OCRResultView(image: image, results: vs.ocrResult)
                            .frame(width: image.size.width, height: image.size.height)
                            .onTapGesture { vs.send(.imageTapped) }
                    } else {
                        Button {
                            vs.send(.buttonTapped)
                        } label: {
                            Text("초 고급 기술, 사진에서 일본어 추출")
                        }
                    }
                    VStack {
                        ForEach(vs.ocrResult) { result in
                            Text(result.string)
                        }
                    }
                }
            }
        }
    }
}

