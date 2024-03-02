//
//  AddUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddUnit {
    @ObservableState
    struct State: Equatable {
        var set: StudySet?
        var alreadyExist: StudyUnit?
        var inputUnit = InputUnit.State()
        @Presents var alert: AlertState<AlertAction>?
        
        mutating func clearInput() {
            inputUnit.kanjiInput.text = ""
            inputUnit.kanjiInput.hurigana = .init(hurigana: "")
            inputUnit.kanjiInput.isEditing = true
            inputUnit.meaningInput.text = ""
        }
        
        mutating func setNoSetAlert() {
            alert = AlertState<AlertAction> {
                TextState("선택된 단어장 없음")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("단어장을 선택 해주세요.")
            }
        }
        
        mutating func setExistAlert() {
            let kanjiText = inputUnit.kanjiInput.text
            alert = AlertState<AlertAction> {
                TextState("표제어 중복")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("\(kanjiText)와 동일한 단어가 존재합니다")
            }
        }
    }
    
    enum Action: Equatable {
        case inputUnit(InputUnit.Action)
        case add
        case cancel
        case added(StudyUnit)
        case alert(PresentationAction<AlertAction>)
    }
    
    enum AlertAction: Equatable {}
    
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .inputUnit(.alreadyExist(let unit)):
                state.alreadyExist = unit
                if let unit = unit {
                    state.setExistAlert()
                    state.inputUnit.meaningInput.text = unit.meaningText
                }
            case .add:
                guard let set = state.set else {
                    state.setNoSetAlert()
                    return .none
                }
                if let alreadyExist = state.alreadyExist {
                    let input = StudyUnitInput(
                        type: alreadyExist.type,
                        kanjiText: alreadyExist.kanjiText,
                        meaningText: state.inputUnit.meaningInput.text)
                    let edited = try! unitClient.edit(alreadyExist, input)
                    let unit = try! unitClient.insertExisting(set, edited)
                    return .send(.added(unit))
                } else {
                    let input = StudyUnitInput(
                        type: .word,
                        kanjiText: state.inputUnit.kanjiInput.hurigana.hurigana,
                        meaningText: state.inputUnit.meaningInput.text)
                    let unit = try! unitClient.insert(set, input)
                    return .send(.added(unit))
                }
            default: break
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
        Scope(state: \.inputUnit, action: \.inputUnit) { InputUnit() }
    }
    
}

struct AddUnitView: View {
    
   @Bindable var store: StoreOf<AddUnit>
    
    var body: some View {
        VStack(spacing: 40) {
            UnitInputView(store: store.scope(
                state: \.inputUnit,
                action: AddUnit.Action.inputUnit)
            )
            HStack(spacing: 100) {
                Button("취소") {
                    store.send(.cancel)
                }
                .buttonStyle(InputButtonStyle())
                Button("추가") {
                    store.send(.add)
                }
                .buttonStyle(InputButtonStyle(isAble: store.inputUnit.ableToAdd))
                .disabled(!store.inputUnit.ableToAdd)
                .keyboardShortcut(.return, modifiers: .control)
            }
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}
