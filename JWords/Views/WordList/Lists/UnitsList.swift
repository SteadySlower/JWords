//
//  UnitsList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

struct UnitsList: Reducer {
    struct State: Equatable {
        var _units: IdentifiedArrayOf<StudyOneUnit.State>
        var units: IdentifiedArrayOf<StudyOneUnit.State> {
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
                    StudyOneUnit.State(unit: $0,
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
        case unit(StudyOneUnit.State.ID, StudyOneUnit.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
        .forEach(\._units, action: /Action.unit) {
            StudyOneUnit()
        }
    }
    
}

struct StudyList: View {
    
    let store: StoreOf<UnitsList>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(store.scope(
                state: \.units,
                action: UnitsList.Action.unit)
            ) {
                StudyCell(store: $0)
            }
        }
    }
    
}

#Preview {
    StudyList(store: Store(
        initialState: UnitsList.State(
            units: .mock,
            frontType: .kanji,
            isLocked: false
        ),
        reducer: { UnitsList() })
    )
}
