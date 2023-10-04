//
//  AddSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI

struct AddSet: ReducerProtocol {
    
    struct State: Equatable {
        var inputSet: InputSet.State = .init()
        
        var ableToAdd: Bool {
            !inputSet.title.isEmpty
        }
    }
    
    enum Action: Equatable {
        case inputSet(InputSet.Action)
        case add
        case cancel
        case added
    }
    
    @Dependency(\.studySetClient) var setClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .add:
                let input = StudySetInput(
                    title: state.inputSet.title,
                    isAutoSchedule: true,
                    preferredFrontType: state.inputSet.frontType
                )
                try! setClient.insert(input)
                return .task { .added }
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

struct AddSetView: View {
    
    let store: StoreOf<AddSet>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack(spacing: 30) {
                InputSetView(store: store.scope(
                    state: \.inputSet,
                    action: AddSet.Action.inputSet)
                )
                HStack {
                    Spacer()
                    Button("취소") {
                        vs.send(.cancel)
                    }
                    .buttonStyle(InputButtonStyle())
                    Spacer()
                    Button("추가") {
                        vs.send(.add)
                    }
                    .buttonStyle(InputButtonStyle(isAble: vs.ableToAdd))
                    .disabled(!vs.ableToAdd)
                    Spacer()
                }
            }
            .padding(.horizontal, 10)
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    AddSetView(store: Store(
        initialState: AddSet.State(),
        reducer: AddSet())
    )
}

