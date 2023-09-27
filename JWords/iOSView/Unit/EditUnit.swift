//
//  EditUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI

struct EditUnit: ReducerProtocol {
    
    struct State: Equatable {
        let unit: StudyUnit
        var inputUnit = InputUnit.State()
        var alert: AlertState<Action>?
        
        var kanjitext: String {
            inputUnit.kanjiInput.hurigana.hurigana
        }
        
        var meaningText: String {
            inputUnit.meaningInput.text
        }
        
        fileprivate mutating func setUneditableAlert() {
            let kanjiText = inputUnit.kanjiInput.text
            alert = AlertState<Action> {
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
        case cancel
        case edited(StudyUnit)
        case alertDismissed
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .inputUnit(let action):
                switch action {
                case .alreadyExist(let unit):
                    if unit != nil {
                        state.setUneditableAlert()
                    }
                    return .none
                default: return .none
                }
            case .edit:
                let unit = try! cd.editUnit(
                    of: state.unit,
                    type: .word,
                    kanjiText: state.kanjitext,
                    meaningText: state.meaningText)
                return .task { .edited(unit) }
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
            .alert(
              store.scope(state: \.alert),
              dismiss: .alertDismissed
            )
        }
    }
}
