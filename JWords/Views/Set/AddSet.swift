//
//  AddSet.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AddSet {
    @ObservableState
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
        case added(StudySet)
    }
    
    @Dependency(\.studySetClient) var setClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .add:
                let input = StudySetInput(
                    title: state.inputSet.title,
                    isAutoSchedule: true,
                    preferredFrontType: state.inputSet.frontType
                )
                let set = try! setClient.insert(input)
                return .send(.added(set))
            default: break
            }
            return .none
        }
        Scope(state: \.inputSet, action: \.inputSet) { InputSet() }
    }
    
}

struct AddSetView: View {
    
    let store: StoreOf<AddSet>
    
    var body: some View {
        VStack(spacing: 30) {
            InputSetView(store: store.scope(
                state: \.inputSet,
                action: \.inputSet)
            )
            HStack {
                Spacer()
                Button("취소") {
                    store.send(.cancel)
                }
                .buttonStyle(InputButtonStyle())
                Spacer()
                Button("추가") {
                    store.send(.add)
                }
                .buttonStyle(InputButtonStyle(isAble: store.ableToAdd))
                .disabled(!store.ableToAdd)
                Spacer()
            }
        }
        .padding(.horizontal, 10)
        .presentationDetents([.medium])
    }
}

#Preview {
    AddSetView(store: Store(
        initialState: AddSet.State(),
        reducer: { AddSet() })
    )
}

