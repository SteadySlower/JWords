//
//  MacStudyView.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct MacWordList: ReducerProtocol {
    struct State: Equatable {
        
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

struct MacStudyView: View {
    
    let store: StoreOf<MacWordList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

struct MacStudyView_Previews: PreviewProvider {
    static var previews: some View {
        MacStudyView(
            store: Store(
                initialState: MacWordList.State(),
                reducer: MacWordList()._printChanges()
            )
        )
    }
}
