//
//  File.swift
//  
//
//  Created by JW Moon on 5/6/24.
//

import ComposableArchitecture
import Model
import StudySet
import StudySetClient

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
    
    @Dependency(StudySetClient.self) var setClient
    @Dependency(\.dismiss) var dismiss
    
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
            case .cancel:
                return .run { _ in await self.dismiss() }
            default: break
            }
            return .none
        }
        Scope(state: \.inputSet, action: \.inputSet) { InputSet() }
    }
    
}
