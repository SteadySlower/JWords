//
//  File.swift
//  
//
//  Created by JW Moon on 4/20/24.
//

import ComposableArchitecture
import SwiftUI
import Model
import CommonUI
import StudySetClient

@Reducer
public struct AddSet {
    @ObservableState
    public struct State: Equatable {
        var inputSet: InputSet.State = .init()
        
        var ableToAdd: Bool {
            !inputSet.title.isEmpty
        }
    }
    
    public enum Action: Equatable {
        case inputSet(InputSet.Action)
        case add
        case cancel
        case added(StudySet)
    }
    
    @Dependency(StudySetClient.self) var setClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some Reducer<State, Action> {
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
            case .cancel:
                return .run { _ in await self.dismiss() }
            default: break
            }
            return .none
        }
        Scope(state: \.inputSet, action: \.inputSet) { InputSet() }
    }
    
}

public struct AddSetSheet: View {
    
    let store: StoreOf<AddSet>
    
    public var body: some View {
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


