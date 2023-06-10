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
    
    enum Field: Hashable {
        case kanji, meaning
    }
    
    private let cd = CoreDataClient.shared
    
    struct State: Equatable {
        @BindingState var focusedField: Field?
        
        var mode: Mode
        var unitType: UnitType
        var meaningText: String
        var kanjiText: String
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
        
        init(mode: Mode) {
            self.mode = mode
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
                self.meaningText = unit.meaningText ?? ""
                if unit.type != .kanji {
                    self.huriText = EditHuriganaText.State(hurigana: unit.kanjiText ?? "")
                    self.kanjiText = HuriganaConverter.shared.huriToKanjiText(from: unit.kanjiText ?? "")
                    isEditingKanji = false
                } else {
                    self.kanjiText = unit.kanjiText ?? ""
                    self.huriText = EditHuriganaText.State(hurigana: "")
                }
                return
            case .editKanji(let kanji):
                self.unitType = .kanji
                self.meaningText = kanji.meaningText ?? ""
                self.kanjiText = kanji.kanjiText ?? ""
                self.huriText = EditHuriganaText.State(hurigana: kanji.kanjiText ?? "")
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
            !kanjiText.isEmpty && !meaningText.isEmpty
        }
        
        var okButtonText: String {
            switch mode {
            case .insert(_), .addExist(_, _):
                return "추가"
            case .editUnit(_), .editKanji(_):
                return "수정"
            }
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
    
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case setUnitType(UnitType)
        case focusFieldChanged(Field?)
        case onTab(Field)
        case updateKanjiText(String)
        case updateMeaningText(String)
        case editHuriText(action: EditHuriganaText.Action)
        case editKanjiTextButtonTapped
        case checkIfExist(String)
        case meaningButtonTapped
        case addButtonTapped
        case showErrorAlert(AppError)
        case alertDismissed
        case cancelButtonTapped
        case addUnit
        case unitEdited(StudyUnit)
        case unitAdded(StudyUnit)
        case kanjiEdited(Kanji)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .focusFieldChanged(let field):
                if let field = field,
                   field == .meaning,
                   state.unitType != .kanji,
                   !state.kanjiText.isEmpty,
                   state.isEditingKanji == true {
                    let hurigana = HuriganaConverter.shared.convert(state.kanjiText)
                    state.huriText = EditHuriganaText.State(hurigana: hurigana)
                    state.isEditingKanji = false
                }
                return .none
            case .setUnitType(let type):
                switch state.mode {
                case .editKanji(_):
                    break
                default:
                    state.unitType = type
                    if type == .kanji {
                        state.isEditingKanji = true
                    }
                }
                return .none
            case .updateKanjiText(let text):
                switch state.mode {
                case .addExist(let set, _):
                    state.mode = .insert(set: set)
                default:
                    break
                }
                if text.hasTab {
                    return .task { .onTab(.kanji) }
                }
                state.kanjiText = text
                return .none
            case .updateMeaningText(let text):
                if text.hasTab {
                    return .task { .onTab(.meaning) }
                }
                state.meaningText = text
                return .none
            case .onTab(let field):
                switch field {
                case .kanji:
                    state.focusedField = .meaning
                case .meaning:
                    break
                }
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
                        state.meaningText = unit.meaningText ?? ""
                        state.setExistAlert()
                    } else {
                        state.mode = .insert(set: set)
                    }
                case .editUnit(_), .editKanji(_):
                    break
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
                                                   kanjiImageID: nil,
                                                   meaningText: state.meaningText,
                                                   meaningImageID: nil)
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
    @FocusState var focusedField: AddingUnit.Field?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Picker("", selection: vs.binding(
                    get: \.unitType,
                    send: AddingUnit.Action.setUnitType)
                ) {
                    ForEach(UnitType.allCases, id: \.self) {
                        Text($0.description)
                    }
                }
                .pickerStyle(.segmented)
                HStack {
                    if vs.isEditingKanji {
                        TextEditor(text: vs.binding(get: \.kanjiText, send: AddingUnit.Action.updateKanjiText))
                            .border(.black)
                            .focused($focusedField, equals: .kanji)
                    } else {
                        VStack {
                            EditableHuriganaText(store: store.scope(
                                state: \.huriText,
                                action: AddingUnit.Action.editHuriText(action:))
                            )
                            Spacer()
                        }
                    }
                    if !vs.isEditingKanji {
                        Button("수정") { vs.send(.editKanjiTextButtonTapped) }
                            .disabled(vs.unitType == .kanji)
                    }
                }
                .frame(height: 100)
                HStack {
                    TextEditor(text: vs.binding(get: \.meaningText, send: AddingUnit.Action.updateMeaningText))
                        .border(.black)
                        .frame(height: 100)
                        .focused($focusedField, equals: .meaning)
                    Button("검색") { vs.send(.meaningButtonTapped) }
                }
                .padding(.bottom, 20)
                HStack(spacing: 100) {
                    Button("취소") { vs.send(.cancelButtonTapped) }
                    Button(vs.okButtonText) { vs.send(.addButtonTapped) }
                        .disabled(!vs.ableToAdd)
                }
            }
            .padding(.horizontal, 10)
            .presentationDetents([.medium])
            .onChange(of: focusedField, perform: { vs.send(.focusFieldChanged($0)) })
            .onChange(of: vs.checkExistQuery, perform: { vs.send(.checkIfExist($0))})
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
            .synchronize(vs.binding(\.$focusedField), self.$focusedField)
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
