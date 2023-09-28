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

        var ocr: GetWordsFromOCR.State?
        var showCameraScanner: Bool = false
        var getImageButtons = GetImageForOCR.State()
        
        var selectSet = SelectStudySet.State(pickerName: "")
        var addUnit = AddUnit.State()
        var alert: AlertState<Action>?
        
        var showOCR: Bool { ocr != nil }
    }
    
    enum Action: Equatable {
        case selectSet(SelectStudySet.Action)
        case addUnit(AddUnit.Action)
        case showCameraScanner(Bool)
        case dismissAlert
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
//            case .getImageButtons(let action):
//            case .imageFetched(let image):
//                guard let resizedImage = resizeImage(image) else { return .none }
//                state.ocr = .init(resizedImage)
//                return .merge(
//                    .task {
//                        await .japaneseOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: resizedImage, lang: .japanese) })
//                    },
//                    .task {
//                        await .koreanOcrResponse(TaskResult { try await OCRClient.shared.ocr(from: resizedImage, lang: .korean) })
//                    }
//                )
//            case .koreanOcrResponse(.success(let results)):
//                state.ocr?.koreanOcrResult = results
//                return .none
//            case .japaneseOcrResponse(.success(let results)):
//                state.ocr?.japaneseOcrResult = results
//                return .none
            case .selectSet(let action):
                switch action {
                case .idUpdated:
                    if let set = state.selectSet.selectedSet {
                        state.addUnit.set = set
                    } else {
                        state.addUnit.set = nil
                    }
                default:
                    break
                }
                return .none
            case .addUnit(let action):
                switch action {
                case .added:
                    state.addUnit.clearInput()
                    state.selectSet.onUnitAdded()
                    return .none
                default:
                    return .none
                }
//            case .getWordsFromOCR(let action):
//                switch action {
//                case .ocrMarkTapped(let lang, let text):
//                    switch lang {
//                    case .korean:
//                        state.addUnit.inputUnit.meaningInput.text = text
//                        return .none
//                    case .japanese:
//                        state.addUnit.inputUnit.kanjiInput.isEditing = true
//                        state.addUnit.inputUnit.kanjiInput.hurigana = .init(hurigana: "")
//                        state.addUnit.inputUnit.kanjiInput.text = text
//                        return .none
//                    }
//                case .removeImageButtonTapped:
//                    state.ocr = nil
//                    return .none
//                }
            case .dismissAlert:
                state.alert = nil
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.addUnit, action: /Action.addUnit) {
            AddUnit()
        }
        Scope(state: \.selectSet, action: /Action.selectSet) {
            SelectStudySet()
        }
    }
}


// TODO: move somewhere proper

fileprivate func dismissKeyBoard() {
    #if os(iOS)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
//                        if vs.showOCR {
//                            VStack(spacing: 20) {
//                                Text("스캔 결과")
//                                    .font(.system(size: 20))
//                                    .bold()
//                                    .leadingAlignment()
//                                    .padding(.leading, 10)
//                            }
//                        } else {
//                            GetImageForOCRView(store: store.scope(
//                                state: \.getImageButtons,
//                                action: AddUnitWithOCR.Action.getImageButtons)
//                            )
//                            .padding(.vertical, 10)
//                        }
                        StudySetPicker(store: store.scope(
                            state: \.selectSet,
                            action: AddUnitWithOCR.Action.selectSet)
                        )
                        AddUnitView(store: store.scope(
                            state: \.addUnit,
                            action: AddUnitWithOCR.Action.addUnit)
                        )
                    }
                }
                .padding(.vertical, 10)
            }
            .withBannerAD()
            .padding(.horizontal, 10)
            .navigationTitle("단어 스캐너")
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

