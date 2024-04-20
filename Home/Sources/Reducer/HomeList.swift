//
//  File.swift
//  
//
//  Created by JW Moon on 4/16/24.
//

import ComposableArchitecture
import Model
import StudySetClient
import StudyUnitClient

@Reducer
public struct HomeList {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        var sets: [StudySet] = []
        var isLoading: Bool = false
        var includeClosed: Bool = false
        
        @Presents var destination: Destination.State?
        
        public init() {
            self.sets = []
            self.isLoading = false
            self.includeClosed = false
            self.destination = nil
        }
        
        mutating func clear() {
            sets = []
            destination = nil
        }
    }
    
    @Reducer(state: .equatable, action: .equatable)
    public enum Destination {
        case addSet(AddSet)
    }
    
    public enum Action: Equatable {
        case fetchSets
        case toStudySet(StudySet)
        case setIncludeClosed(Bool)
        case toAddSet
        
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Dependency(StudySetClient.self) var setClient
    @Dependency(StudyUnitClient.self) var unitClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                fetchSets(&state)
            case .setIncludeClosed(let bool):
                state.includeClosed = bool
                fetchSets(&state)
            case .toAddSet:
                state.destination = .addSet(.init())
            case .destination(.presented(.addSet(.added(let set)))):
                state.sets.insert(set, at: 0)
                state.destination = nil
            default: break
            }
            return .none
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    private func fetchSets(_ state: inout HomeList.State) {
        state.clear()
        state.sets = try! setClient.fetch(state.includeClosed)
    }

}
