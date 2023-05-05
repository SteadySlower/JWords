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
        var meaningText: String = ""
        var kanjiText: String = ""
        var huriText = EditHuriganaText.State(hurigana: "")
        
        var isEditingKanji = true
    }
    
    enum Action: Equatable {
        case updateWordText(String)
        case editHuriText(action: EditHuriganaText.Action)
        case kanjiTextButtonTapped
        case addButtonTapped
        case cancelButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateWordText(let text):
                state.kanjiText = text
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
                HStack {
                    VStack {
                        if vs.isEditingKanji {
                            TextEditor(text: vs.binding(get: \.kanjiText, send: AddingUnit.Action.updateWordText))
                                .border(.black)
                        } else {
                            EditableHuriganaText(store: store.scope(
                                state: \.huriText,
                                action: AddingUnit.Action.editHuriText(action:))
                            )
                        }
                        Spacer()
                    }
                    Button(vs.isEditingKanji ? "변환" : "수정") { vs.send(.kanjiTextButtonTapped) }
                }
                .frame(height: 100)
                .padding(10)

                HStack {
                    Button("추가") { vs.send(.addButtonTapped) }
                    Button("취소") { vs.send(.cancelButtonTapped) }
                }
            }
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
