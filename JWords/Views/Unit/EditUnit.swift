//
//  EditUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI
import Huri

@Reducer
struct EditUnit {
    @ObservableState
    struct State: Equatable {
        let unit: StudyUnit
        var inputUnit = InputUnit.State()
        @Presents var alert: AlertState<AlertAction>?
        
        init(unit: StudyUnit, convertedKanjiText: String, huris: [Huri]) {
            self.unit = unit
            self.inputUnit = InputUnit.State()
            inputUnit.kanjiInput.text = convertedKanjiText
            inputUnit.kanjiInput.huris = huris
            inputUnit.kanjiInput.isEditing = false
            inputUnit.meaningInput.text = unit.meaningText
        }
        
        var kanjiText: String {
            inputUnit.kanjiInput.huris.toHurigana()
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
    
    @CasePathable
    enum AlertAction: Equatable {
        case cancel
    }
    
    @Dependency(StudyUnitClient.self) var unitClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .inputUnit(.alreadyExist(let unit)):
                if let unit = unit,
                   unit.id != state.unit.id {
                    state.setUneditableAlert()
                }
            case .edit:
                let input = StudyUnitInput(
                    type: .word,
                    kanjiText: state.kanjiText,
                    meaningText: state.meaningText)
                let unit = try! unitClient.edit(state.unit, input)
                return .send(.edited(unit))
            case .alert(.presented(.cancel)):
                return .run { _ in await self.dismiss() }
            case .cancel:
                return .run { _ in await self.dismiss() }
            default: break
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
        Scope(state: \.inputUnit, action: \.inputUnit) { InputUnit() }
    }
    
}

struct EditUnitView: View {
    
    @Bindable var store: StoreOf<EditUnit>
    
    var body: some View {
        VStack(spacing: 40) {
            UnitInputView(store: store.scope(
                state: \.inputUnit,
                action: \.inputUnit)
            )
            HStack(spacing: 100) {
                Button("취소") {
                    store.send(.cancel)
                }
                .buttonStyle(InputButtonStyle())
                Button("수정") {
                    store.send(.edit)
                }
                .buttonStyle(InputButtonStyle(isAble: store.inputUnit.ableToAdd))
                .disabled(!store.inputUnit.ableToAdd)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
