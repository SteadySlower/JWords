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
        public var isDeleteMode: Bool = false
        var includeClosed: Bool = false
        @Presents var alert: AlertState<AlertAction>?
        
        public init() {
            self.sets = []
            self.isLoading = false
            self.includeClosed = false
        }
        
        public mutating func clear() {
            sets = []
        }
        
        mutating func setDeleteAlert(_ set: StudySet) {
            alert = AlertState<AlertAction> {
                TextState("단어장 삭제")
            } actions: {
                ButtonState(role: .destructive, action: .delete(set)) {
                    TextState("삭제")
                }
                ButtonState(role: .cancel) {
                    TextState("취소")
                }
            } message: {
                TextState("\(set.title) 을(를) 삭제합니다.")
            }
        }
        
    }
    
    public enum Action: Equatable {
        case fetchSets
        case toStudySet(StudySet)
        case toDeleteSet(StudySet)
        case setIncludeClosed(Bool)
        case alert(PresentationAction<AlertAction>)
    }
    
    public enum AlertAction: Equatable {
        case delete(StudySet)
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
            case .toDeleteSet(let set):
                state.setDeleteAlert(set)
            case .alert(.presented(.delete(let set))):
                // TODO: 단어장 삭제
                print("디버그: \(set.title) 삭제")
                state.isDeleteMode = false
            default: break
            }
            return .none
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
    private func fetchSets(_ state: inout StudySetList.State) {
        state.clear()
        state.sets = try! setClient.fetch(state.includeClosed)
    }

}

