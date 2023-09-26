//
//  MeaningInput.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import ComposableArchitecture

struct MeaningInput: ReducerProtocol {

    struct State: Equatable {
        var text: String
    }
    
    enum Action: Equatable {
        case updateText(String)
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                state.text = text
                return .none
            }
        }
    }
    
}

