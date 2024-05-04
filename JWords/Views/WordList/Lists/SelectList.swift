//
//  SelectList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI
import Model

@Reducer
struct SelectUnits {
    @ObservableState
    struct State: Equatable {
        var units: IdentifiedArrayOf<SelectUnit.State>
        
        init(units: [StudyUnit], frontType: FrontType) {
            self.units = IdentifiedArray(uniqueElements: units.map { SelectUnit.State(unit: $0, frontType: frontType) })
        }
        
        init(idArray: IdentifiedArrayOf<SelectUnit.State>) {
            self.units = idArray
        }
        
    }
    
    enum Action: Equatable {
        case unit(IdentifiedActionOf<SelectUnit>)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
        .forEach(\.units, action: \.unit) { SelectUnit() }
    }
}

struct SelectList: View {
    
    let store: StoreOf<SelectUnits>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEach(
                store.scope(state: \.units, action: \.unit),
                id: \.state.id
            ) { SelectionCell(store: $0) }
        }
    }
    
}

#Preview {
    SelectList(store: Store(
        initialState: SelectUnits.State(
            units: .mock,
            frontType: .kanji
        ),
        reducer: { SelectUnits() })
    )
}

