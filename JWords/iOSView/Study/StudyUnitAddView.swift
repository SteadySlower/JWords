//
//  WordAddView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct AddingUnit: ReducerProtocol {
    
    private let cd = CoreDataClient.shared
    
    struct State: Equatable {
        let set: StudySet?
        let unit: StudyUnit?
        var unitType: UnitType
        var meaningText: String
        var kanjiText: String
        var huriText: EditHuriganaText.State
        var alert: AlertState<Action>?
        
        var isEditingKanji = true
        
        init(set: StudySet) {
            self.set = set
            self.unit = nil
            self.unitType = .word
            self.meaningText = ""
            self.kanjiText = ""
            self.huriText = EditHuriganaText.State(hurigana: "")
            self.alert = nil
        }
        
        init(set: StudySet, unit: StudyUnit) {
            self.set = set
            self.unit = unit
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
        
        var ableToAdd: Bool {
            !kanjiText.isEmpty && !meaningText.isEmpty
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
    
    }
    
    enum Action: Equatable {
        case setUnitType(UnitType)
        case updateKanjiText(String)
        case updateMeaningText(String)
        case editHuriText(action: EditHuriganaText.Action)
        case kanjiTextButtonTapped
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
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .setUnitType(let type):
                state.unitType = type
                if type == .kanji {
                    state.isEditingKanji = true
                }
                return .none
            case .updateKanjiText(let text):
                state.kanjiText = text
                return .none
            case .updateMeaningText(let text):
                state.meaningText = text
                return .none
            case .kanjiTextButtonTapped:
                if !state.isEditingKanji {
                    state.isEditingKanji = true
                    return .none
                }
                let hurigana = HuriganaConverter.shared.convert(state.kanjiText)
                state.huriText = EditHuriganaText.State(hurigana: hurigana)
                state.isEditingKanji = false
                return .none
            case .addButtonTapped:
                if state.unitType != .kanji && state.isEditingKanji {
                    return .task { .showErrorAlert(.notConvertedToHuri) }
                } else if state.unitType == .kanji && state.kanjiText.count > 1 {
                    return .task { .showErrorAlert(.KanjiTooLong) }
                }
                print("디버그: \(state.huriText.hurigana)")
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
                if let set = state.set {
                    let added = try! cd.insertUnit(in: set,
                                  type: state.unitType,
                                  kanjiText: state.unitType != .kanji ? state.huriText.hurigana : state.kanjiText,
                                  kanjiImageID: nil,
                                  meaningText: state.meaningText,
                                  meaningImageID: nil)
                    return .task { .unitAdded(added) }
                } else if let unit = state.unit {
                    let edited = try! cd.editUnit(of: unit,
                                                  type: state.unitType,
                                                  kanjiText: state.unitType != .kanji ? state.huriText.hurigana : state.kanjiText,
                                                  kanjiImageID: nil,
                                                  meaningText: state.meaningText,
                                                  meaningImageID: nil)
                    return .task { .unitEdited(edited) }
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
                    } else {
                        VStack {
                            EditableHuriganaText(store: store.scope(
                                state: \.huriText,
                                action: AddingUnit.Action.editHuriText(action:))
                            )
                            Spacer()
                        }
                    }
                    Button(vs.isEditingKanji ? "변환" : "수정") { vs.send(.kanjiTextButtonTapped) }
                        .disabled(vs.unitType == .kanji)
                }
                .frame(height: 100)
                HStack {
                    TextEditor(text: vs.binding(get: \.meaningText, send: AddingUnit.Action.updateMeaningText))
                        .border(.black)
                        .frame(height: 100)
                    Button("검색") { vs.send(.meaningButtonTapped) }
                }
                .padding(.bottom, 20)
                HStack(spacing: 100) {
                    Button("취소") { vs.send(.cancelButtonTapped) }
                    if vs.unit != nil && vs.set != nil {
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
            .alert(
              self.store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
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
