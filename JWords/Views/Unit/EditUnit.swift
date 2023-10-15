//
//  EditUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI

struct EditUnit: Reducer {
    
    struct State: Equatable {
        let unit: StudyUnit
        var inputUnit = InputUnit.State()
        @PresentationState var alert: AlertState<AlertAction>?
        
        init(unit: StudyUnit) {
            self.unit = unit
            self.inputUnit = InputUnit.State()
            inputUnit.kanjiInput.text = HuriganaConverter.shared.huriToKanjiText(from: unit.kanjiText)
            inputUnit.kanjiInput.hurigana = EditHuriganaText.State(hurigana: unit.kanjiText)
            inputUnit.kanjiInput.isEditing = false
            inputUnit.meaningInput.text = unit.meaningText
        }
        
        var kanjiText: String {
            inputUnit.kanjiInput.hurigana.hurigana
        }
        
        var meaningText: String {
            inputUnit.meaningInput.text
        }
        
        mutating func setUneditableAlert() {
            let kanjiText = inputUnit.kanjiInput.text
            alert = AlertState<AlertAction> {
                TextState("표제어 중복")
            } actions: {
                ButtonState(action: .cancel) {
                    TextState("취소")
                }
            } message: {
                TextState("\(kanjiText)가 이미 존재합니다. 똑같은 표제어로 수정할 수 없습니다.")
            }
        }
    }
    
    enum Action: Equatable {
        case inputUnit(InputUnit.Action)
        case edit
        case edited(StudyUnit)
        case cancel
        case alert(PresentationAction<AlertAction>)
    }
    
    enum AlertAction: Equatable {
        case cancel
    }
    
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .inputUnit(let action):
                switch action {
                case .alreadyExist(let unit):
                    if let unit = unit,
                       unit.kanjiText != state.unit.kanjiText {
                        state.setUneditableAlert()
                    }
                    return .none
                default: return .none
                }
            case .edit:
                let input = StudyUnitInput(
                    type: .word,
                    kanjiText: state.kanjiText,
                    meaningText: state.meaningText)
                let unit = try! unitClient.edit(state.unit, input)
                return .send(.edited(unit))
            case .alert(let action):
                if action == .presented(.cancel) {
                    return .send(.cancel)
                }
                return .none
            default: return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
        Scope(state: \.inputUnit, action: /Action.inputUnit) {
            InputUnit()
        }
    }
    
}

struct EditUnitView: View {
    
    let store: StoreOf<EditUnit>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 40) {
                UnitInputView(store: store.scope(
                    state: \.inputUnit,
                    action: EditUnit.Action.inputUnit)
                )
                HStack(spacing: 100) {
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle())
                    Button("수정") {
                        vs.send(.edit)
                    }
                    .buttonStyle(InputButtonStyle(isAble: vs.inputUnit.ableToAdd))
                    .disabled(!vs.inputUnit.ableToAdd)
                }
            }
            .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
        }
    }
}
