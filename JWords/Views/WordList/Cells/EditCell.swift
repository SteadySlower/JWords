//
//  EditCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/19.
//

import SwiftUI
import Combine
import ComposableArchitecture

@Reducer
struct ToEditUnit {
    @ObservableState
    struct State: Equatable, Identifiable {
        let id: String
        let unit: StudyUnit
        let frontType: FrontType
        
        init(unit: StudyUnit, frontType: FrontType = .kanji) {
            self.id = unit.id
            self.unit = unit
            self.frontType = frontType
        }
        
    }
    
    enum Action: Equatable {
        case cellTapped(StudyUnit)
    }
    
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                return .none
            }
        }
    }

}

struct EditCell: View {
    
    let store: StoreOf<ToEditUnit>
    
    var body: some View {
        BaseCell(unit: store.unit, frontType: store.frontType)
            .overlay(
                Image(systemName: "pencil")
                    .resizable()
                    .foregroundColor(.green)
                    .opacity(0.5)
                    .scaledToFit()
                    .padding()
            )
            .onTapGesture { store.send(.cellTapped(store.unit)) }
    }
    
}
