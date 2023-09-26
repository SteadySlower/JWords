//
//  AddUnitInSet.swift
//  JWords
//
//  Created by JW Moon on 2023/09/27.
//

import ComposableArchitecture
import SwiftUI

struct AddUnitInSet: ReducerProtocol {
    
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
    
}
