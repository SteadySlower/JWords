//
//  OCRInputView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/07.
//


// TODO: This Reducer is interim, when AddUnit Reducer is refactored, remove this

import SwiftUI
import ComposableArchitecture

struct OCRInput: ReducerProtocol {
    
    enum Mode: Equatable {
        case insert
        case addExist(existing: StudyUnit)
    }
    
    enum AlertType: Equatable {
        case alreadyExist(String), noSet, noHuri, noMeaning
        
        var title: String {
            switch self {
            case .alreadyExist: return "표제어 중복"
            case .noSet: return "단어장 선택 안됨"
            case .noHuri: return "가나 변환 필요"
            case .noMeaning: return "뜻 없음"
            }
        }
        
        var message: String {
            switch self {
            case .alreadyExist(let exist): return "\(exist)와 동일한 단어가 존재합니다"
            case .noSet: return "단어장을 선택해주세요"
            case .noHuri: return "저장하기 전에 후리가나로 변환해야 합니다."
            case .noMeaning: return "뜻이 없습니다."
            }
        }
    }
    
    struct State: Equatable {
        var mode: Mode = .insert
        var selectSet = SelectStudySet.State(pickerName: "저장할 단어장을 선택하세요")
        var kanjiString: String = ""
        var meaningString: String = ""
        var huriText: EditHuriganaText.State?
        
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
    }
    
    enum Action: Equatable {
        case updateKanjiString(String)
        case updateMeaningString(String)
        case convertButtonTapped
        case revertButtonTapped
        case saveButtonTapped
        case selectSet(SelectStudySet.Action)
        case huriText(EditHuriganaText.Action)
        case showAlert(AlertType)
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateKanjiString(let string):
                state.kanjiString = string
                return .none
            case .updateMeaningString(let string):
                state.meaningString = string
                return .none
            case .convertButtonTapped:
                let huri = HuriganaConverter.shared.convert(state.kanjiString)
                state.huriText = EditHuriganaText.State(hurigana: huri)
                let unit = try! cd.checkIfExist(huri)
                if let unit = unit {
                    state.mode = .addExist(existing: unit)
                    state.meaningString = unit.meaningText ?? ""
                    return .task { [existing = state.kanjiString] in
                            .showAlert(.alreadyExist(existing)) }
                } else {
                    state.mode = .insert
                    return .none
                }
            case .revertButtonTapped:
                state.huriText = nil
                state.mode = .insert
                return .none
            case .saveButtonTapped:
                guard let set = state.selectSet.selectedSet else {
                    return .task { .showAlert(.noSet) }
                }
                guard let huri = state.huriString else {
                    return .task { .showAlert(.noHuri) }
                }
                guard !state.meaningString.isEmpty else {
                    return .task { .showAlert(.noMeaning) }
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

func dismissKeyBoard() {
    #if os(iOS)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    #endif
}

struct OCRInputView: View {
    
    let store: StoreOf<OCRInput>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                StudySetPicker(store: store.scope(
                    state: \.selectSet,
                    action: OCRInput.Action.selectSet)
                )
                HStack {
                    VStack {
                        Text("単語")
                        if vs.huriText != nil {
                            IfLetStore(self.store.scope(state: \.huriText,
                                                        action: OCRInput.Action.huriText)
                            ) {
                                EditableHuriganaText(store: $0)
                            }
                            Button("수정") {
                                vs.send(.revertButtonTapped)
                            }
                        } else {
                            TextEditor(text: vs.binding(get: \.kanjiString, send: OCRInput.Action.updateKanjiString))
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
                        TextEditor(text: vs.binding(get: \.meaningString, send: OCRInput.Action.updateMeaningString))
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
    }
}
