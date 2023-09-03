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
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
    }
    
    enum Action: Equatable {
        case buttonTapped
        case imageTapped
        case imageFetched
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                guard let fetchedImage = pasteBoardClient.fetchImage() else { return .none }
                state.image = fetchedImage
                return .merge(
                    .task {
                        await .japaneseOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: fetchedImage, lang: .japanese) })
                    },
                    .task {
                        await .koreanOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: fetchedImage, lang: .korean) })
                    }
                )
            case .imageTapped:
                state.image = nil
                state.koreanOcrResult = []
                state.japaneseOcrResult = []
                return .none
            case .koreanOcrResponse(.success(let results)):
                state.koreanOcrResult = results
                return .none
            case .japaneseOcrResponse(.success(let results)):
                state.japaneseOcrResult = results
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
                        OCRResultView(image: image, koreanResults: vs.koreanOcrResult, japaneseResults: vs.japaneseOcrResult)
                            .frame(width: image.size.width, height: image.size.height)
                            .onTapGesture { vs.send(.imageTapped) }
                    } else {
                        Button {
                            vs.send(.buttonTapped)
                        } label: {
                            Text("초 고급 기술, 사진에서 일본어 추출")
                        }
                    }
                    HStack {
                        VStack {
                            Text("일본어")
                            ForEach(vs.japaneseOcrResult) { result in
                                Text(result.string)
                            }
                        }
                        VStack {
                            Text("한글")
                            ForEach(vs.koreanOcrResult) { result in
                                Text(result.string)
                            }
                        }
                    }

                }
            }
        }
    }
}

