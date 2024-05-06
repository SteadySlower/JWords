//
//  File.swift
//  
//
//  Created by JW Moon on 5/6/24.
//

import ComposableArchitecture
import Model

@Reducer
public struct StudySetList {
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        public var sets: [StudySet] = []
        public var isLoading: Bool = false
        var includeClosed: Bool = false
        
        public init() {
            self.sets = []
            self.isLoading = false
            self.includeClosed = false
        }
        
        public mutating func clear() {
            sets = []
        }
    }
    
    public enum Action: Equatable {
        case fetchSets
        case toStudySet(StudySet)
        case setIncludeClosed(Bool)
    }
    
    @Dependency(StudySetClient.self) var setClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .fetchSets:
                fetchSets(&state)
            case .setIncludeClosed(let bool):
                state.includeClosed = bool
                fetchSets(&state)
            default: break
            }
            return .none
        }
    }
    
    private func fetchSets(_ state: inout StudySetList.State) {
        state.clear()
        state.sets = try! setClient.fetch(state.includeClosed)
    }

}

