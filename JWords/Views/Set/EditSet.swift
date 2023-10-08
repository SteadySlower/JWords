//
//  EditSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI

struct EditSet: Reducer {
    
    struct State: Equatable {
        let set: StudySet
        var inputSet: InputSet.State
        
        var ableToEdit: Bool {
            !inputSet.title.isEmpty
        }
        
        init(_ set: StudySet) {
            self.set = set
            self.inputSet = .init(
                title: set.title,
                frontType: set.preferredFrontType)
        }
    }
    
    enum Action: Equatable {
        case inputSet(InputSet.Action)
        case edit
        case cancel
        case edited(StudySet)
    }
    
    @Dependency(\.studySetClient) var setClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .edit:
                let input = StudySetInput(
                    title: state.inputSet.title,
                    isAutoSchedule: true,
                    preferredFrontType: state.inputSet.frontType
                )
                let edited = try! setClient.update(state.set, input)
                return .send(.edited(edited))
            default: return .none
            }
        }
        Scope(
            state: \.inputSet,
            action: /Action.inputSet,
            child: { InputSet() }
        )
    }
    
}

struct EditSetView: View {
    
    let store: StoreOf<EditSet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 30) {
                InputSetView(store: store.scope(
                    state: \.inputSet,
                    action: EditSet.Action.inputSet)
                )
                HStack {
                    Spacer()
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle())
                    Spacer()
                    Button("수정") {
                        vs.send(.edit)
                    }
                    .buttonStyle(InputButtonStyle(isAble: vs.ableToEdit))
                    .disabled(!vs.ableToEdit)
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    EditSetView(store: Store(
        initialState: EditSet.State(.init(index: 0)),
        reducer: { EditSet() })
    )
}

