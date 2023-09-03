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
        
        enum Mode: Equatable {
            case insert(set: StudySet)
            case addExist(set: StudySet, existing: StudyUnit)
        }
        
        // OCR
        var image: InputImageType?
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
        
        // input
        var selectSet = SelectStudySet.State(pickerName: "단어장")
        
        var kanjiString: String = ""
        var meaningString: String = ""
        var huriText: EditHuriganaText.State?
    }
    
    enum Action: Equatable {
        case buttonTapped
        case imageTapped
        case imageFetched
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case ocrTapped(lang: OCRLang, string: String)
        
        case selectSet(SelectStudySet.Action)
        case updateKanjiString(String)
        case updateMeaningString(String)
        case convertButtonTapped
        case revertButtonTapped
        case huriText(EditHuriganaText.Action)
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
                    state.huriText = nil
                    state.kanjiString = string
                }
                return .none
            case .convertButtonTapped:
                let huri = HuriganaConverter.shared.convert(state.kanjiString)
                state.huriText = EditHuriganaText.State(hurigana: huri)
                return .none
            case .revertButtonTapped:
                state.huriText = nil
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.huriText, action: /Action.huriText) {
            EditHuriganaText()
        }
        Scope(state: \.selectSet, action: /Action.selectSet) {
            SelectStudySet()
        }
    }

}


struct OCRView: View {
    
    let store: StoreOf<OCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack {
                    StudySetPicker(store: store.scope(
                        state: \.selectSet,
                        action: OCR.Action.selectSet)
                    )
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
                            if vs.huriText != nil {
                                IfLetStore(self.store.scope(state: \.huriText,
                                                            action: OCR.Action.huriText)
                                ) {
                                    EditableHuriganaText(store: $0)
                                }
                                Button("수정") {
                                    vs.send(.revertButtonTapped)
                                }
                            } else {
                                TextEditor(text: vs.binding(get: \.kanjiString, send: OCR.Action.updateKanjiString))
                                    .font(.system(size: 30))
                                    .border(.black)
                                    .frame(height: 100)
                                Button("변환") {
                                    vs.send(.convertButtonTapped)
                                }
                            }

                        }
                        VStack {
                            Text("意味")
                            TextEditor(text: vs.binding(get: \.meaningString, send: OCR.Action.updateMeaningString))
                                .font(.system(size: 30))
                                .border(.black)
                                .frame(height: 100)
                        }
                    }
                    Button("저장") {
                        
                    }
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 10)
        }
    }
}

