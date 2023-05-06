//
//  WordAddView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct AddingUnit: ReducerProtocol {
    struct State: Equatable {
        var unitType: UnitType = .word
        var meaningText: String = ""
        var kanjiText: String = ""
        var huriText = EditHuriganaText.State(hurigana: "")
        var alert: AlertState<Action>?
        
        var isEditingKanji = true
        
        var ableToAdd: Bool {
            !kanjiText.isEmpty && !meaningText.isEmpty
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
        case cancelButtonTapped
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
                return .none
            case .showErrorAlert(let error):
                state.alert = error.simpleAlert(action: Action.self)
                return .none
            case .alertDismissed:
                state.alert = nil
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
                    Button("추가") { vs.send(.addButtonTapped) }
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

struct StudyUnitAddView_Previews: PreviewProvider {
    static var previews: some View {
        StudyUnitAddView(store: Store(
            initialState: AddingUnit.State(),
            reducer: AddingUnit())
        )
    }
}
