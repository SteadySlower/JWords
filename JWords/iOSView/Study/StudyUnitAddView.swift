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
        case editUnit(set: StudySet?, unit: StudyUnit)
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
        
        // when adding new unit
        init(set: StudySet) {
            self.mode = .insert(set: set)
            self.unitType = .word
            self.meaningText = ""
            self.kanjiText = ""
            self.huriText = EditHuriganaText.State(hurigana: "")
            self.alert = nil
        }
        
        // when editing existing unit
        init(set: StudySet?, unit: StudyUnit) {
            self.mode = .editUnit(set: set, unit: unit)
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
        }
        
        // when Editing Kanji
        init(kanji: Kanji) {
            self.mode = .editKanji(kanji: kanji)
            self.unitType = .kanji
            self.meaningText = kanji.meaningText ?? ""
            self.kanjiText = kanji.kanjiText ?? ""
            self.huriText = EditHuriganaText.State(hurigana: kanji.kanjiText ?? "")
            self.isEditingKanji = false
            self.isKanjiEditable = false
        }
        
        var ableToAdd: Bool {
            !kanjiText.isEmpty && !meaningText.isEmpty
        }
        
        var showDeleteButton: Bool {
            switch mode {
            case .editUnit(_, _):
                return true
            default:
                return false
            }
        }

        mutating func setDeleteAlertState() {
            guard let set = set else { return }
            alert = AlertState<Action> {
                TextState("단어 삭제")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
                ButtonState(role: .destructive, action: .deleteUnit) {
                    TextState("삭제")
                }
            } message: {
                TextState("이 단어를 '\(set.title)'에서 삭제합니다.\n(다른 단어장에서는 삭제되지 않습니다.)")
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
        case updateKanjiText(String)
        case updateMeaningText(String)
        case editHuriText(action: EditHuriganaText.Action)
        case editKanjiTextButtonTapped
        case checkIfExist(String)
        case meaningButtonTapped
        case addButtonTapped
        case showErrorAlert(AppError)
        case alertDismissed
        case deleteButtonTapped
        case cancelButtonTapped
        case addUnit
        case deleteUnit
        case unitEdited(StudyUnit)
        case unitDeleted(StudyUnit)
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
                if state.kanji != nil { return .none }
                state.unitType = type
                if type == .kanji {
                    state.isEditingKanji = true
                }
                return .none
            case .updateKanjiText(let text):
                switch state.mode {
                case .addExist:
                    state.mode = .insert
                default:
                    break
                }
                state.kanjiText = text
                return .none
            case .updateMeaningText(let text):
                state.meaningText = text
                return .none
            case .editKanjiTextButtonTapped:
                state.isEditingKanji = true
                return .none
            case .checkIfExist(let query):
                guard state.mode != .editUnit && state.mode != .editKanji else { return .none }
                let unit = try! cd.checkIfExist(query)
                if let unit = unit {
                    state.mode = .addExist(existing: unit)
                    state.meaningText = unit.meaningText ?? ""
                    state.setExistAlert()
                } else {
                    state.mode = .insert
                }
                return .none
            case .addButtonTapped:
                if state.unitType != .kanji && state.isEditingKanji {
                    return .task { .showErrorAlert(.notConvertedToHuri) }
                } else if state.unitType == .kanji && state.kanjiText.count > 1 {
                    return .task { .showErrorAlert(.KanjiTooLong) }
                }
                return .task { .addUnit }
            case .deleteButtonTapped:
                state.setDeleteAlertState()
                return .none
            case .showErrorAlert(let error):
                state.alert = error.simpleAlert(action: Action.self)
                return .none
            case .alertDismissed:
                state.alert = nil
                return .none
            case .addUnit:
                switch state.mode {
                case .insert:
                    guard let set = state.set else { return .none }
                    let added = try! cd.insertUnit(in: set,
                                                   type: state.unitType,
                                                   kanjiText: state.unitType != .kanji ? state.huriText.hurigana : state.kanjiText,
                                                   kanjiImageID: nil,
                                                   meaningText: state.meaningText,
                                                   meaningImageID: nil)
                    return .task { .unitAdded(added) }
                case .editUnit:
                    guard let unit = state.unit else { return .none }
                    let edited = try! cd.editUnit(of: unit,
                                                  type: state.unitType,
                                                  kanjiText: state.unitType != .kanji ? state.huriText.hurigana : state.kanjiText,
                                                  kanjiImageID: nil,
                                                  meaningText: state.meaningText,
                                                  meaningImageID: nil)
                    return .task { .unitEdited(edited) }
                case .editKanji:
                    guard let kanji = state.kanji else { return .none }
                    let edited = try! cd.editKanji(kanji: kanji, meaningText: state.meaningText)
                    return .task { .kanjiEdited(edited) }
                case .addExist(let unit):
                    guard let set = state.set else { return .none }
                    let addedExist = try! cd.addExistingUnit(unit: unit,
                                                             meaningText: state.meaningText,
                                                             in: set)
                    return .task { .unitAdded(addedExist) }
                }
            case .deleteUnit:
                if let unit = state.unit,
                   let set = state.set {
                    let deleted = try! cd.removeUnit(unit, from: set)
                    return .task { .unitDeleted(deleted) }
                }
                return .none
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
                    if vs.showDeleteButton {
                        Button("삭제") {
                            vs.send(.deleteButtonTapped)
                        }.foregroundColor(.red)
                    }
                    Button(vs.unit == nil ? "추가" : "수정") { vs.send(.addButtonTapped) }
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
