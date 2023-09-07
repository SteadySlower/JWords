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
        var getImageButtons = GetImageForOCR.State()
        var koreanOcrResult: [OCRResult] = []
        var japaneseOcrResult: [OCRResult] = []
        
        var input = OCRInput.State()
        var alert: AlertState<Action>?
        
        fileprivate mutating func setAlert(_ type: OCRInput.AlertType) {
            alert = AlertState<Action> {
                TextState(type.title)
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState(type.message)
            }
        }
    }
    
    enum Action: Equatable {
        case imageTapped
        case imageFetched
        case getImageButtons(GetImageForOCR.Action)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case ocrTapped(lang: OCRLang, string: String)
        case input(OCRInput.Action)
        case dismissAlert
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImageButtons(let action):
                switch action {
                case .clipBoardButtonTapped:
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
                case .cameraButtonTapped:
                    // TODO: add logic
                    return .none
                }
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
            case .ocrTapped(let lang, let string):
                switch lang {
                case .korean:
                    state.input.meaningString = string
                case .japanese:
                    state.input.huriText = nil
                    state.input.kanjiString = string
                }
                return .none
            case .input(let action):
                switch action {
                case .showAlert(let type):
                    state.setAlert(type)
                    return .none
                default:
                    return .none
                }
            case .dismissAlert:
                state.alert = nil
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.getImageButtons, action: /Action.getImageButtons) {
            GetImageForOCR()
        }
        Scope(state: \.input, action: /Action.input) {
            OCRInput()
        }
    }
}

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
                    if let image = vs.image {
                        VStack {
                            OCRResultView(image: image, koreanResults: vs.koreanOcrResult, japaneseResults: vs.japaneseOcrResult) { vs.send(.ocrTapped(lang: $0, string: $1)) }
                                .frame(width: image.size.width, height: image.size.height)
                            Button("이미지 리셋") {
                                vs.send(.imageTapped)
                            }
                        }
                    } else {
                        ImageGetterButtons(store: store.scope(
                            state: \.getImageButtons,
                            action: OCR.Action.getImageButtons)
                        )
                        .padding(.vertical, 20)
                    }
                    OCRInputView(store: store.scope(
                        state: \.input,
                        action: OCR.Action.input)
                    )
                }
            }
            .padding(.bottom, 50)
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
              dismiss: .dismissAlert
            )
        }
    }
}

