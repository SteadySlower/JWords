//
//  DeleteList.swift
//  JWords
//
//  Created by JW Moon on 2023/09/28.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct DeleteUnits {
    struct State: Equatable {
        var units: IdentifiedArrayOf<DeleteUnit.State>
        
        init(units: [StudyUnit], frontType: FrontType) {
            self.units = IdentifiedArray(uniqueElements: units.map { DeleteUnit.State(unit: $0, frontType: frontType) })
        }
        
    }
    
    enum Action: Equatable {
        case units(IdentifiedActionOf<DeleteUnit>)
    }
    
    var body: some Reducer<State, Action> {
        EmptyReducer()
        .forEach(\.units, action: \.units) { DeleteUnit() }
    }
}

struct DeleteList: View {
    
    let store: StoreOf<DeleteUnits>
    
    var body: some View {
        LazyVStack(spacing: 32) {
            ForEachStore(
              store.scope(
                state: \.units,
                action: DeleteUnits.Action.units)
            ) {
                DeleteCell(store: $0)
            }
        }
    }
    
}

#Preview {
    DeleteList(store: Store(
        initialState: DeleteUnits.State(
            units: .mock,
            frontType: .kanji
        ),
        reducer:{ DeleteUnits() })
    )
}
