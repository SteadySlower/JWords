//
//  AddUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI

struct AddUnit: ReducerProtocol {
    
    struct State: Equatable {
        var set: StudySet?
        var alreadyExist: StudyUnit?
        var inputUnit = InputUnit.State()
        var alert: AlertState<Action>?
        
        mutating func clearInput() {
            inputUnit.kanjiInput.text = ""
            inputUnit.kanjiInput.hurigana = .init(hurigana: "")
            inputUnit.kanjiInput.isEditing = true
            inputUnit.meaningInput.text = ""
        }
        
        fileprivate mutating func setNoSetAlert() {
            alert = AlertState<Action> {
                TextState("선택된 단어장 없음")
            } actions: {
                ButtonState(role: .none) {
                    TextState("확인")
                }
            } message: {
                TextState("단어장을 선택 해주세요.")
            }
        }
        
        fileprivate mutating func setExistAlert() {
            let kanjiText = inputUnit.kanjiInput.text
            alert = AlertState<Action> {
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
        case alertDismissed
    }
    
    @Dependency(\.studyUnitClient) var unitClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .inputUnit(let action):
                switch action {
                case .alreadyExist(let unit):
                    state.alreadyExist = unit
                    if unit != nil {
                        state.setExistAlert()
                    }
                    return .none
                default: return .none
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
                    return .task { .added(unit) }
                } else {
                    let input = StudyUnitInput(
                        type: .word,
                        kanjiText: state.inputUnit.kanjiInput.hurigana.hurigana,
                        meaningText: state.inputUnit.meaningInput.text)
                    let unit = try! unitClient.insert(set, input)
                    return .task { .added(unit) }
                }
            case .alertDismissed:
                state.alert = nil
                return .none
            default: return .none
            }
        }
        Scope(state: \.inputUnit, action: /Action.inputUnit) {
            InputUnit()
        }
    }
    
}

struct AddUnitView: View {
    
    let store: StoreOf<AddUnit>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 40) {
                UnitInputView(store: store.scope(
                    state: \.inputUnit,
                    action: AddUnit.Action.inputUnit)
                )
                HStack(spacing: 100) {
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle())
                    Button("추가") {
                        vs.send(.add)
                    }
                    .buttonStyle(InputButtonStyle(isAble: vs.inputUnit.ableToAdd))
                    .disabled(!vs.inputUnit.ableToAdd)
                }
            }
            .alert(
              store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
}
