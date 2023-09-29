//
//  EditCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/19.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct EditWord: ReducerProtocol {
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
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                return .none
            }
        }
    }

}

struct EditCell: View {
    
    let store: StoreOf<EditWord>
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            BaseCell(unit: vs.unit,
                     frontType: vs.frontType)
                .overlay(
                    Image(systemName: "pencil")
                        .resizable()
                        .foregroundColor(.green)
                        .opacity(0.5)
                        .scaledToFit()
                        .padding()
                )
                .onTapGesture { vs.send(.cellTapped(vs.unit)) }
        }
    }
    
}
