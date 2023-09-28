//
//  MacAddUnitView.swift
//  JWords
//
//  Created by JW Moon on 2023/06/10.
//

import SwiftUI
import ComposableArchitecture

struct SelectSetAddUnit: ReducerProtocol {
    
    struct State: Equatable {
        var selectSet = SelectStudySet.State(pickerName: "단어장 선택")
    }
    
    enum Action: Equatable {
        case selectSet(action: SelectStudySet.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            return .none
        }
        Scope(state: \.selectSet, action: /Action.selectSet(action:)) {
            SelectStudySet()
        }
    }
}

struct MacAddUnitView: View {
    
    let store: StoreOf<SelectSetAddUnit>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                StudySetPicker(store: store.scope(
                    state: \.selectSet,
                    action: SelectSetAddUnit.Action.selectSet(action:))
                )
            }
        }
    }
}
