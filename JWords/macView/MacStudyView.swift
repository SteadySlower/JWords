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
        var setList = [StudySet]()
        var selectedID: String? = nil
        
        var selectedSet: StudySet? {
            setList.first(where: { $0.id == selectedID })
        }
    }
    
    enum Action: Equatable {
        case updateNowSet(String?)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateNowSet(let id):
                state.selectedID = id
                return .none
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
            VStack {
                Picker("", selection:
                        vs.binding(
                             get: \.selectedID,
                             send: MacWordList.Action.updateNowSet)
                ) {
                    Text("선택된 단어장 없음")
                        .tag(nil as String?)
                    ForEach(vs.setList, id: \.id) { book in
                        Text(book.title)
                            .tag(book.id as String?)
                    }
                }
            }
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
