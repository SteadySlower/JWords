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
        var sets: [KanjiSet]
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
    
    let store: StoreOf<KanjiSetList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack(spacing: 8) {
                    VStack {}
                    .frame(height: 20)
                    ForEach(vs.sets, id: \.id) { set in
//                        SetCell(studySet: set) { vs.send(.homeCellTapped(set)) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
//
//#Preview {
//    KanjiSetListView()
//}
