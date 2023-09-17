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
        
        var selectSet = SelectStudySet.State(pickerName: "")
        
        var addUnit: AddingUnit.State?
        var alert: AlertState<Action>?
        
        var showOCR: Bool { ocr != nil }
    }
    
    enum Action: Equatable {
        case ocr(OCR.Action)
        case getImageButtons(GetImageForOCR.Action)
        case cameraImageSelected(InputImageType)
        case koreanOcrResponse(TaskResult<[OCRResult]>)
        case japaneseOcrResponse(TaskResult<[OCRResult]>)
        case selectSet(SelectStudySet.Action)
        case addUnit(AddingUnit.Action)
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
            case .selectSet(let action):
                switch action {
                case .idUpdated:
                    if let set = state.selectSet.selectedSet {
                        state.addUnit = AddingUnit.State(mode: .insert(set: set), cancelButtonHidden: true)
                    } else {
                        state.addUnit = nil
                    }
                default:
                    break
                }
                return .none
            case .addUnit(let action):
                switch action {
                case .unitAdded:
                    state.selectSet.onUnitAdded()
                    return .none
                default:
                    return .none
                }
            case .ocr(let action):
                switch action {
                case .ocrMarkTapped(let lang, let text):
                    switch lang {
                    case .korean:
                        state.addUnit?.meaningText = text
                        return .none
                    case .japanese:
                        state.addUnit?.isEditingKanji = true
                        state.addUnit?.kanjiText = text
                        return .none
                    }
                case .removeImageButtonTapped:
                    state.ocr = nil
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
        .ifLet(\.addUnit, action: /Action.addUnit) {
            AddingUnit()
        }
        Scope(state: \.getImageButtons, action: /Action.getImageButtons) {
            GetImageForOCR()
        }
        Scope(state: \.selectSet, action: /Action.selectSet) {
            SelectStudySet()
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
            ScrollView(showsIndicators: false) {
                ZStack {
                    Color.white
                        .onTapGesture { dismissKeyBoard() }
                    VStack(spacing: 35) {
                        if vs.showOCR {
                            VStack(spacing: 20) {
                                Text("스캔 결과")
                                    .font(.system(size: 20))
                                    .bold()
                                    .leadingAlignment()
                                    .padding(.leading, 10)
                                IfLetStore(self.store.scope(state: \.ocr,
                                                            action: AddUnitWithOCR.Action.ocr)
                                ) {
                                    OCRView(store: $0)
                                }
                            }
                        } else {
                            VStack {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("이미지 스캔하기")
                                        .font(.system(size: 20))
                                        .bold()
                                    Text("정면에서 찍을 수록 인식률이 높습니다.\n글자 크기가 클 수록 인식률이 높습니다.\n요미가나가 없이 한자만 있는 텍스트의 인식률이 높습니다.\n단어 사이에 간격이 넓을 수록 인식률이 높습니다.")
                                        .font(.system(size: 12))
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding([.leading, .bottom], 10)
                                .leadingAlignment()
                                ImageGetterButtons(store: store.scope(
                                    state: \.getImageButtons,
                                    action: AddUnitWithOCR.Action.getImageButtons)
                                )
                            }
                            .padding(.vertical, 10)
                        }
                        StudySetPicker(store: store.scope(
                            state: \.selectSet,
                            action: AddUnitWithOCR.Action.selectSet)
                        )
                        .padding(.bottom, 35)
                        IfLetStore(store.scope(
                            state: \.addUnit,
                            action: AddUnitWithOCR.Action.addUnit))
                       {
                           StudyUnitAddView(store: $0)
                       }
                    }
                }
                .padding(.vertical, 10)
            }
            .withBannerAD()
            .padding(.horizontal, 10)
            .navigationTitle("단어 스캐너")
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

