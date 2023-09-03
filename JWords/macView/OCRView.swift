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
        // OCR
        var image: InputImageType?
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
        
        // input
        var kanjiString: String = ""
        var meaningString: String = ""
    }
    
    enum Action: Equatable {
        case buttonTapped
        case imageTapped
        case imageFetched
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case ocrTapped(lang: OCRLang, string: String)
        
        case updateKanjiString(String)
        case updateMeaningString(String)
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
            case .updateKanjiString(let string):
                state.kanjiString = string
                return .none
            case .updateMeaningString(let string):
                state.meaningString = string
                return .none
            case .ocrTapped(let lang, let string):
                switch lang {
                case .korean:
                    state.meaningString = string
                case .japanese:
                    state.kanjiString = string
                }
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
                        VStack {
                            OCRResultView(image: image, koreanResults: vs.koreanOcrResult, japaneseResults: vs.japaneseOcrResult) { vs.send(.ocrTapped(lang: $0, string: $1)) }
                                .frame(width: image.size.width, height: image.size.height)
                            Button("이미지 리셋") {
                                vs.send(.imageTapped)
                            }
                        }
                    } else {
                        Button {
                            vs.send(.buttonTapped)
                        } label: {
                            Text("초 고급 기술, 사진에서 일본어 추출")
                        }
                    }
                    HStack {
                        VStack {
                            Text("単語")
                            TextEditor(text: vs.binding(get: \.kanjiString, send: OCR.Action.updateKanjiString))
                                .font(.system(size: 30))
                                .border(.black)
                                .frame(height: 100)
                        }
                        VStack {
                            Text("意味")
                            TextEditor(text: vs.binding(get: \.meaningString, send: OCR.Action.updateMeaningString))
                                .font(.system(size: 30))
                                .border(.black)
                                .frame(height: 100)
                        }
                    }

                }
            }
            .padding(.top, 50)
        }
    }
}

