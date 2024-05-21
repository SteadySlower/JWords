//
//  UnitsList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI
import Model

@Reducer
struct UnitsList {
    @ObservableState
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

        mutating func setFilter(_ filter: UnitFilter) {
            self.filter = filter
        }
        
        mutating func onDeleted(_ unit: StudyUnit) {
            _units.remove(id: unit.id)
        }
    }
    
    enum Action: Equatable {
        case unit(IdentifiedActionOf<StudyOneUnit>)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
        .forEach(\._units, action: \.unit) { StudyOneUnit() }
    }
    
}

struct StudyList: View {
    
    let store: StoreOf<UnitsList>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEach(
                store.scope(state: \.units,action: \.unit),
                id: \.state.id
            ) { StudyCell(store: $0) }
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
