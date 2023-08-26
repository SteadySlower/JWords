//
//  DeleteCell.swift
//  JWords
//
//  Created by JW Moon on 2023/08/26.
//

import SwiftUI
import Kingfisher
import ComposableArchitecture

struct DeleteWord: ReducerProtocol {
    
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
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { _, _ in .none }
    }
    
}

struct DeleteCell: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct DeleteCell_Previews: PreviewProvider {
    static var previews: some View {
        DeleteCell()
    }
}
