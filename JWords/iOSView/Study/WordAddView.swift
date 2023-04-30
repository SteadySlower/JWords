//
//  WordAddView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct WordAdding: ReducerProtocol {
    struct State: Equatable {
        var meaningText: String = ""
        var wordText: String = ""
        var huriText: String = ""
    }
    
    enum Action: Equatable {
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
    }

}

struct WordAddView: View {
    
    let store: StoreOf<WordAdding>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                
            }
        }
    }
}

struct WordAddView_Previews: PreviewProvider {
    static var previews: some View {
        WordAddView(store: Store(
            initialState: WordAdding.State(),
            reducer: WordAdding())
        )
    }
}
