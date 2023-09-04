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
            case insert
            case addExist(existing: StudyUnit)
        }
        
        // OCR
        var image: InputImageType?
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
        
        // input
        var mode: Mode = .insert
        var selectSet = SelectStudySet.State(pickerName: "단어장")
        var kanjiString: String = ""
        var meaningString: String = ""
        var huriText: EditHuriganaText.State?
        var alert: AlertState<Action>?
        
        var huriString: String? {
            huriText?.hurigana
        }
        
        fileprivate mutating func clearUserInput() {
            mode = .insert
            kanjiString = ""
            meaningString = ""
            huriText = nil
            #if os(iOS)
            dismissKeyBoard()
            #endif
        }
        
        fileprivate mutating func setExistAlert() {
            let alreadyExist = kanjiString
            alert = AlertState<Action> {
                TextState("표제어 중복")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("\(alreadyExist)와 동일한 단어가 존재합니다")
            }
        }
        
        fileprivate mutating func setNoSetAlert() {
            alert = AlertState<Action> {
                TextState("단어장 선택 안됨")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("단어장을 선택해주세요")
            }
        }
        
        fileprivate mutating func setNoHuriAlert() {
            alert = AlertState<Action> {
                TextState("가나 변환 필요")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("저장하기 전에 후리가나로 변환해야 합니다.")
            }
        }
        
        fileprivate mutating func setNoMeaningAlert() {
            alert = AlertState<Action> {
                TextState("뜻 없음")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("뜻이 없습니다.")
            }
        }
        
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
        case alertDismissed
        case saveButtonTapped
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    private let cd = CoreDataClient.shared
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .buttonTapped:
                guard
                    let fetchedImage = pasteBoardClient.fetchImage(),
                    let resizedImage = resizeImage(fetchedImage,
                                                   to: .init(
                                                    width: Constants.Size.deviceWidth - 10,
                                                    height: Constants.Size.deviceHeight / 2)
                    ) else { return .none }
                state.image = resizedImage
                return .merge(
                    .task {
                        await .japaneseOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: resizedImage, lang: .japanese) })
                    },
                    .task {
                        await .koreanOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: resizedImage, lang: .korean) })
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
                let unit = try! cd.checkIfExist(huri)
                if let unit = unit {
                    state.mode = .addExist(existing: unit)
                    state.meaningString = unit.meaningText ?? ""
                    state.setExistAlert()
                } else {
                    state.mode = .insert
                }
                return .none
            case .revertButtonTapped:
                state.huriText = nil
                state.mode = .insert
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case .saveButtonTapped:
                guard let set = state.selectSet.selectedSet else {
                    state.setNoSetAlert()
                    return .none
                }
                guard let huri = state.huriString else {
                    state.setNoHuriAlert()
                    return .none
                }
                guard !state.meaningString.isEmpty else {
                    state.setNoMeaningAlert()
                    return .none
                }
                switch state.mode {
                case .insert:
                    _ = try! cd.insertUnit(in: set,
                                           type: .word,
                                           kanjiText: huri,
                                           meaningText: state.meaningString)
                case .addExist(let unit):
                    _ = try! cd.addExistingUnit(unit: unit,
                                                meaningText: state.meaningString,
                                                in: set)
                }
                state.clearUserInput()
                state.selectSet.onUnitAdded()
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

// TODO: move this to somewhere proper

#if os(iOS)
fileprivate func dismissKeyBoard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
#endif

fileprivate func resizeImage(_ image: InputImageType, to newSize: CGSize) -> InputImageType? {
    #if os(iOS)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
    #elseif os(macOS)
    // Convert NSImage to CGImage
    let newSizeWidth = newSize.width
    let newSizeHeight = newSize.height

     let newImage = NSImage(size: newSize)

     newImage.lockFocus()

     NSGraphicsContext.current?.imageInterpolation = .high

     image.draw(in: NSRect(x: 0, y: 0, width: newSizeWidth, height: newSizeHeight),
                from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                operation: .sourceOver,
                fraction: 1.0)

     newImage.unlockFocus()

     return newImage
     #endif
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
                            Text("클립보드에서 이미지 가져오기")
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
                                .disabled(vs.kanjiString.isEmpty)
                            }
                            Spacer()
                        }
                        VStack {
                            Text("意味")
                            TextEditor(text: vs.binding(get: \.meaningString, send: OCR.Action.updateMeaningString))
                                .font(.system(size: 30))
                                .border(.black)
                                .frame(height: 100)
                            Spacer()
                        }
                    }
                    Button(vs.mode == .insert
                           ? "새 단어 추가"
                           : "기존 단어 단어장에 추가"
                    ) {
                        vs.send(.saveButtonTapped)
                    }
                }
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 10)
            .navigationTitle("단어 스캔으로 입력하기")
            .toolbar {
                ToolbarItem {
                    Button {
                        dismissKeyBoard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
}

