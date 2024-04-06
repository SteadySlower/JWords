//
//  DeleteCell.swift
//  JWords
//
//  Created by JW Moon on 2023/08/26.
//

import SwiftUI
import ComposableArchitecture
import Model

@Reducer
struct DeleteUnit {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: String
        let unit: StudyUnit
        let frontType: FrontType
        
        init(unit: StudyUnit, frontType: FrontType) {
            self.id = unit.id
            self.unit = unit
            self.frontType = frontType
        }
    }
    
    enum Action: Equatable {
        case cellTapped
    }
    
    var body: some Reducer<State, Action> { EmptyReducer() }
    
}

struct DeleteCell: View {
    
    let store: StoreOf<DeleteUnit>
    
    var body: some View {
        BaseCell(unit: store.unit, frontType: store.frontType)
            .overlay(
                Image(systemName: "trash")
                    .resizable()
                    .foregroundColor(.red)
                    .opacity(0.5)
                    .scaledToFit()
                    .padding()
            )
            .onTapGesture { store.send(.cellTapped) }
    }
}
