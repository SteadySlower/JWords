//
//  KanjiSetList.swift
//  JWords
//
//  Created by JW Moon on 2/4/24.
//

import SwiftUI
import ComposableArchitecture

struct KanjiSetList: Reducer {
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}

struct KanjiSetListView: View {
    var body: some View {
        Text("KanjiSetListView")
    }
}

#Preview {
    KanjiSetListView()
}
