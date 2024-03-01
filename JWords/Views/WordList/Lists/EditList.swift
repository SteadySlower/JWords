//
//  EditList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct EditUnits {
    struct State: Equatable {
        var units: IdentifiedArrayOf<ToEditUnit.State>
        
        init(units: [StudyUnit], frontType: FrontType) {
            self.units = IdentifiedArray(uniqueElements: units.map { ToEditUnit.State(unit: $0, frontType: frontType) })
        }
        
    }
    
    enum Action: Equatable {
        case unit(IdentifiedActionOf<ToEditUnit>)
        case toEditUnitSelected(StudyUnit)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .unit(.element(_, .cellTapped(let unit))):
                return .send(.toEditUnitSelected(unit))
            default: break
            }
            return .none
        }
        .forEach(\.units, action: \.unit) { ToEditUnit() }
    }
}

struct EditList: View {
    
    let store: StoreOf<EditUnits>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(
              store.scope(state: \.units, action: \.unit)
            ) {
                EditCell(store: $0)
            }
        }
    }
    
}

#Preview {
    EditList(store: Store(
        initialState: EditUnits.State(
            units: .mock,
            frontType: .kanji
        ),
        reducer: { EditUnits()._printChanges() })
    )
}
