//
//  AddUnit.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture

struct AddUnit: ReducerProtocol {

    struct State: Equatable {
        
    }
    
    struct Action: Equatable {
        
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default: return .none
            }
        }
    }
    
}
