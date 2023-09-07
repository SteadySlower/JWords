//
//  OCRView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/02.
//

import SwiftUI
import ComposableArchitecture

struct AddUnitWithOCR: ReducerProtocol {
    struct State: Equatable {

        var ocr: OCR.State?
        var showCameraScanner: Bool = false
        var getImageButtons = GetImageForOCR.State()
        
        var input = OCRInput.State()
        var alert: AlertState<Action>?
        
        var showOCR: Bool { ocr != nil }
        
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
        case ocr(OCR.Action)
        case getImageButtons(GetImageForOCR.Action)
        case cameraImageSelected(InputImageType)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case input(OCRInput.Action)
        case showCameraScanner(Bool)
        case imageFetched(InputImageType)
        case dismissAlert
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .getImageButtons(let action):
                switch action {
                case .clipBoardButtonTapped:
                    guard let fetchedImage = pasteBoardClient.fetchImage() else { return .none }
                    return .task { .imageFetched(fetchedImage) }
                case .cameraButtonTapped:
                    state.showCameraScanner = true
                    return .none
                }
            case .imageFetched(let image):
                guard let resizedImage = resizeImage(image) else { return .none }
                state.ocr = .init(resizedImage)
                return .merge(
                    .task {
                        await .japaneseOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: resizedImage, lang: .japanese) })
                    },
                    .task {
                        await .koreanOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: resizedImage, lang: .korean) })
                    }
                )
            case .koreanOcrResponse(.success(let results)):
                state.ocr?.koreanOcrResult = results
                return .none
            case .japaneseOcrResponse(.success(let results)):
                state.ocr?.japaneseOcrResult = results
                return .none
            case .ocr(let action):
                switch action {
                case .ocrMarkTapped(let lang, let text):
                    switch lang {
                    case .korean:
                        state.input.meaningString = text
                    case .japanese:
                        state.input.kanjiString = text
                    }
                    return .none
                case .removeImageButtonTapped:
                    state.ocr = nil
                    return .none
                }
            case .input(let action):
                switch action {
                case .showAlert(let type):
                    state.setAlert(type)
                    return .none
                default:
                    return .none
                }
            case .cameraImageSelected(let image):
                return .task { .imageFetched(image) }
            case .showCameraScanner(let show):
                state.showCameraScanner = show
                return .none
            case .dismissAlert:
                state.alert = nil
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.ocr, action: /Action.ocr) {
            OCR()
        }
        Scope(state: \.getImageButtons, action: /Action.getImageButtons) {
            GetImageForOCR()
        }
        Scope(state: \.input, action: /Action.input) {
            OCRInput()
        }
    }
}

fileprivate func resizeImage(_ image: InputImageType) -> InputImageType? {
    // Calculate Size
    let newWidth = Constants.Size.deviceWidth - 10
    let newHeight = newWidth * (image.size.height / image.size.width)
    let newSize = CGSize(width: newWidth, height: newHeight)
    
    // If image is small enough, return original one
    if image.size.width < newWidth {
        return image
    }
    
    #if os(iOS)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return resizedImage
    #elseif os(macOS)
     let newImage = NSImage(size: newSize)

     newImage.lockFocus()

     NSGraphicsContext.current?.imageInterpolation = .high

     image.draw(in: NSRect(x: 0, y: 0, width: newWidth, height: newHeight),
                from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height),
                operation: .sourceOver,
                fraction: 1.0)

     newImage.unlockFocus()

     return newImage
     #endif
}

struct OCRAddUnitView: View {
    
    let store: StoreOf<AddUnitWithOCR>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack {
                    if vs.showOCR {
                        IfLetStore(self.store.scope(state: \.ocr,
                                                    action: AddUnitWithOCR.Action.ocr)
                        ) {
                            OCRView(store: $0)
                        }
                        .frame(width: vs.ocr?.image.size.width, height: vs.ocr?.image.size.height)
                    } else {
                        ImageGetterButtons(store: store.scope(
                            state: \.getImageButtons,
                            action: AddUnitWithOCR.Action.getImageButtons)
                        )
                        .padding(.vertical, 20)
                    }
                    OCRInputView(store: store.scope(
                        state: \.input,
                        action: AddUnitWithOCR.Action.input)
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
            .sheet(isPresented: vs.binding(
                get: \.showCameraScanner,
                send: AddUnitWithOCR.Action.showCameraScanner)
            ) {
                CameraScanner { vs.send(.cameraImageSelected($0)) }
            }
            #endif
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .dismissAlert
            )
        }
    }
}

