//
//  WordAddView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct AddingUnit: ReducerProtocol {
    
    enum Mode: Equatable {
        case insert(set: StudySet)
        case editUnit(unit: StudyUnit)
        case editKanji(kanji: Kanji)
        case addExist(set: StudySet, existing: StudyUnit)
    }
    
    private let cd = CoreDataClient.shared
    
    struct State: Equatable {
        var mode: Mode
        var unitType: UnitType
        var meaningText: String
        var meaningImage: InputImageType?
        var kanjiText: String
        var kanjiImage: InputImageType?
        var huriText: EditHuriganaText.State
        var alert: AlertState<Action>?
        
        var checkExistQuery: String {
            unitType == .kanji ? kanjiText : huriText.hurigana
        }
        
        var hurigana: String {
            huriText.hurigana
        }
        
        var isEditingKanji: Bool = true
        var isKanjiEditable: Bool = true
        
        var isLoading: Bool = false
        
        let cancelButtonHidden: Bool
        
        init(mode: Mode, cancelButtonHidden: Bool = false) {
            self.mode = mode
            self.cancelButtonHidden = cancelButtonHidden
            switch mode {
            case .insert(_):
                self.unitType = .word
                self.meaningText = ""
                self.kanjiText = ""
                self.huriText = EditHuriganaText.State(hurigana: "")
                self.alert = nil
                return
            case .editUnit(let unit):
                self.mode = .editUnit(unit: unit)
                self.unitType = unit.type
                self.meaningText = unit.meaningText
                if unit.type != .kanji {
                    self.huriText = EditHuriganaText.State(hurigana: unit.kanjiText)
                    self.kanjiText = HuriganaConverter.shared.huriToKanjiText(from: unit.kanjiText)
                    isEditingKanji = false
                } else {
                    self.kanjiText = unit.kanjiText
                    self.huriText = EditHuriganaText.State(hurigana: "")
                }
                return
            case .editKanji(let kanji):
                self.unitType = .kanji
                self.meaningText = kanji.meaningText
                self.kanjiText = kanji.kanjiText
                self.huriText = EditHuriganaText.State(hurigana: kanji.kanjiText)
                self.isEditingKanji = false
                self.isKanjiEditable = false
                return
            default:
                self.unitType = .word
                self.meaningText = ""
                self.kanjiText = ""
                self.huriText = EditHuriganaText.State(hurigana: "")
                self.alert = nil
                return
            }
        }
        
        var ableToAdd: Bool {
            !kanjiText.isEmpty && !meaningText.isEmpty && !isEditingKanji && !hurigana.isEmpty
        }
        
        var okButtonText: String {
            switch mode {
            case .insert(_), .addExist(_, _):
                return "추가"
            case .editUnit(_), .editKanji(_):
                return "수정"
            }
        }
        
        mutating func clearInputs() {
            unitType = .word
            meaningText = ""
            kanjiText = ""
            huriText = EditHuriganaText.State(hurigana: "")
            isEditingKanji = true
        }
        
        mutating func setExistAlert() {
            let kanjiText = self.kanjiText
            let type = unitType
            alert = AlertState<Action> {
                TextState("표제어 중복")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("\(kanjiText)와 동일한 \(type.description)이(가) 존재합니다")
            }
        }
        
        mutating func setUneditableAlert() {
            let kanjiText = self.kanjiText
            alert = AlertState<Action> {
                TextState("표제어 중복")
            } actions: {
                ButtonState(action: .cancelButtonTapped) {
                    TextState("취소")
                }
            } message: {
                TextState("\(kanjiText)가 이미 존재합니다. 똑같은 표제어로 수정할 수 없습니다.")
            }
        }
    
    }
    
    enum Action: Equatable {
        // 한자, 뜻, 후리가나 업데이트 관련
        case updateKanjiText(String)
        case updateMeaningText(String)
        case editHuriText(action: EditHuriganaText.Action)
        case convertToHuriganaButtonTapped
        case editKanjiTextButtonTapped
        
        // 겹치는 단어 관련
        case checkIfExist(String)
        
        // 이미지 버튼 관련
        case kanjiImageButtonTapped
        case meaningImageButtonTapped
        
        // 추가 버튼 관련
        case addButtonTapped
        case cancelButtonTapped
        case addUnit
        
        // 추가/수정 완료시c
        case unitEdited(StudyUnit)
        case unitAdded(StudyUnit)
        case kanjiEdited(Kanji)
        
        // alert 관련
        case showErrorAlert(AppError)
        case alertDismissed
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateKanjiText(let text):
                switch state.mode {
                case .addExist(let set, _):
                    state.mode = .insert(set: set)
                default:
                    break
                }
                state.kanjiText = text
                return .none
            case .updateMeaningText(let text):
                state.meaningText = text
                return .none
            case .convertToHuriganaButtonTapped:
                if state.kanjiText.isEmpty { return .none }
                let hurigana = HuriganaConverter.shared.convert(state.kanjiText)
                state.huriText = EditHuriganaText.State(hurigana: hurigana)
                state.isEditingKanji = false
                return .none
            case .editKanjiTextButtonTapped:
                state.isEditingKanji = true
                return .none
            case .checkIfExist(let query):
                switch state.mode {
                case .insert(let set), .addExist(let set, _):
                    let unit = try! cd.checkIfExist(query)
                    if let unit = unit {
                        state.mode = .addExist(set: set, existing: unit)
                        state.meaningText = unit.meaningText
                        state.setExistAlert()
                    } else {
                        state.mode = .insert(set: set)
                    }
                case .editUnit(let toEdit):
                    let unit = try! cd.checkIfExist(query)
                    if let unit = unit,
                       unit.kanjiText != toEdit.kanjiText {
                        state.setUneditableAlert()
                    }
                default: break
                }
                return .none
            case .kanjiImageButtonTapped:
                if state.kanjiImage == nil {
                    state.kanjiImage = pasteBoardClient.fetchImage()
                } else {
                    state.kanjiImage = nil
                }
                return .none
            case .meaningImageButtonTapped:
                if state.meaningImage == nil {
                    state.meaningImage = pasteBoardClient.fetchImage()
                } else {
                    state.meaningImage = nil
                }
                return .none
            case .addButtonTapped:
                if state.unitType != .kanji && state.isEditingKanji {
                    return .task { .showErrorAlert(.notConvertedToHuri) }
                } else if state.unitType == .kanji && state.kanjiText.count > 1 {
                    return .task { .showErrorAlert(.KanjiTooLong) }
                }
                return .task { .addUnit }
            case .showErrorAlert(let error):
                state.alert = error.simpleAlert(action: Action.self)
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case .addUnit:
                switch state.mode {
                case .insert(let set):
                    let added = try! cd.insertUnit(in: set,
                                                   type: state.unitType,
                                                   kanjiText: state.unitType != .kanji ? state.huriText.hurigana : state.kanjiText,
                                                   meaningText: state.meaningText)
                    state.clearInputs()
                    return .task { .unitAdded(added) }
                case .editUnit(let unit):
                    let edited = try! cd.editUnit(of: unit,
                                                  type: state.unitType,
                                                  kanjiText: state.unitType != .kanji ? state.huriText.hurigana : state.kanjiText,
                                                  kanjiImageID: nil,
                                                  meaningText: state.meaningText,
                                                  meaningImageID: nil)
                    return .task { .unitEdited(edited) }
                case .editKanji(let kanji):
                    let edited = try! cd.editKanji(kanji: kanji, meaningText: state.meaningText)
                    return .task { .kanjiEdited(edited) }
                case .addExist(let set, let unit):
                    let addedExist = try! cd.addExistingUnit(unit: unit,
                                                             meaningText: state.meaningText,
                                                             in: set)
                    state.clearInputs()
                    return .task { .unitAdded(addedExist) }
                }
            default:
                return .none
            }
        }
        Scope(state: \.huriText, action: /Action.editHuriText(action:)) {
            EditHuriganaText()
        }
    }

}

struct StudyUnitAddView: View {
    
    let store: StoreOf<AddingUnit>
    
    private let FONT_SIZE: CGFloat = 30
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                VStack {
                    if vs.isEditingKanji {
                        VStack {
                            title("단어 (앞면)")
                            textEditor(text: vs.binding(get: \.kanjiText, send: AddingUnit.Action.updateKanjiText))
                            button("후리가나 변환") { vs.send(.convertToHuriganaButtonTapped) }
                                .trailingAlignment()
                        }
                    } else {
                        VStack {
                            title("후리가나 (앞면)")
                            ScrollView {
                                EditableHuriganaText(store: store.scope(
                                    state: \.huriText,
                                    action: AddingUnit.Action.editHuriText(action:)),
                                    fontsize: FONT_SIZE
                                )
                                .padding(.horizontal, 5)
                            }
                            .frame(height: 100)
                            .defaultRectangleBackground()
                            button("단어 수정") { vs.send(.editKanjiTextButtonTapped) }
                            .trailingAlignment()
                        }
                    }
                    #if os(macOS)
                    if let kanjiImage = vs.kanjiImage {
                        Image(nsImage: kanjiImage).resizable()
                            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                            .onTapGesture { vs.send(.kanjiImageButtonTapped) }
                    } else {
                        Button("일본어 이미지") { vs.send(.kanjiImageButtonTapped) }
                    }
                    #endif
                }
                .frame(height: vs.kanjiImage == nil ? 100 : 250)
                .padding(.bottom, 40)
                VStack {
                    title("뜻 (뒷면)")
                    textEditor(text: vs.binding(get: \.meaningText, send: AddingUnit.Action.updateMeaningText))
                    #if os(macOS)
                    if let meaningImage = vs.meaningImage {
                        Image(nsImage: meaningImage).resizable()
                            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                            .onTapGesture { vs.send(.meaningImageButtonTapped) }
                    } else {
                        Button("뜻 이미지") { vs.send(.meaningImageButtonTapped) }
                    }
                    #endif
                }
                .frame(height: vs.meaningImage == nil ? 100 : 200)
                .padding(.bottom, 40)
                #if os(iOS)
                HStack(spacing: 100) {
                    inputButton("취소", foregroundColor: .black) { vs.send(.cancelButtonTapped) }
                        .hide(vs.cancelButtonHidden)
                    inputButton(vs.okButtonText,
                                foregroundColor: !vs.ableToAdd ? .gray : .black)
                        { vs.send(.addButtonTapped)  }
                        .disabled(!vs.ableToAdd)
                }
                #elseif os(macOS)
                if !vs.isLoading {
                    button(vs.okButtonText) { vs.send(.addButtonTapped)  }
                        .disabled(!vs.ableToAdd)
                        .keyboardShortcut(.return, modifiers: [.control])
                } else {
                    ProgressView()
                }

                #endif
            }
            .padding(.horizontal, 10)
            .presentationDetents([.medium])
            .onChange(of: vs.checkExistQuery, perform: { vs.send(.checkIfExist($0))})
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
    
    private func title(_ text: String) -> some View {
        Text(text)
            .font(.system(size: FONT_SIZE - 10))
            .bold()
            .leadingAlignment()
    }
    
    private func textEditor(text: Binding<String>) -> some View {
        TextEditor(text: text)
            .font(.system(size: FONT_SIZE))
            .frame(height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .defaultRectangleBackground()
    }
    
    private func button(_ text: String, onTapped: @escaping () -> Void) -> some View {
        Button {
            onTapped()
        } label: {
            Text(text)
                .font(.system(size: FONT_SIZE - 15))
                .foregroundColor(.black)
                .padding(5)
                .defaultRectangleBackground()
        }
    }
    
    private func inputButton(_ text: String, foregroundColor: Color, onTapped: @escaping () -> Void) -> some View {
        Button {
            onTapped()
        } label: {
            Text(text)
                .font(.system(size: FONT_SIZE - 15))
                .foregroundColor(foregroundColor)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .defaultRectangleBackground()
        }
    }
    
    
}

//struct StudyUnitAddView_Previews: PreviewProvider {
//    static var previews: some View {
//        StudyUnitAddView(store: Store(
//            initialState: AddingUnit.State(set: Study),
//            reducer: AddingUnit())
//        )
//    }
//}
