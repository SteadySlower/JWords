//
//  StudyWords.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct StudyWords: ReducerProtocol {
    struct State: Equatable {
        var _units: IdentifiedArrayOf<StudyWord.State>
        var units: IdentifiedArrayOf<StudyWord.State> {
            switch filter {
            case .all:
                return _units
            case .excludeSuccess:
                return _units.filter { $0.studyState != .success }
            case .onlyFail:
                return _units.filter { $0.studyState == .fail }
            }
        }
        var filter: UnitFilter = .all
        
        init(units: [StudyUnit], frontType: FrontType, isLocked: Bool) {
            self._units = IdentifiedArray(
                uniqueElements: units.map {
                    StudyWord.State(unit: $0,
                                    frontType: frontType,
                                    isLocked: isLocked)
                }
            )
        }
        
        mutating func shuffle() {
            _units.shuffle()
        }
        
        mutating func setFilter(_ filter: UnitFilter) {
            self.filter = filter
        }
    }
    
    enum Action: Equatable {
        case word(id: StudyWord.State.ID, action: StudyWord.Action)
        case unitUpdated(unit: StudyUnit)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\._units, action: /Action.word(id:action:)) {
            StudyWord()
        }
    }
    
}

struct StudyList: View {
    
    let store: StoreOf<StudyWords>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(store.scope(
                state: \.units,
                action: StudyWords.Action.word(id:action:))
            ) {
                StudyCell(store: $0)
            }
        }
    }
    
}

#Preview {
    StudyList(store: Store(
        initialState: StudyWords.State(
            units: .mock,
            frontType: .kanji,
            isLocked: false
        ),
        reducer: StudyWords())
    )
}
