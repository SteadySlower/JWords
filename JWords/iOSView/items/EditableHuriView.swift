//
//  EditableHuriView.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct EditHuri: ReducerProtocol {
    struct State: Equatable, Identifiable {
        var id: UUID
        let kanji: String
        var gana: String
        
        init(huri: Huri) {
            self.id = huri.id
            self.kanji = huri.kanji
            self.gana = huri.gana
        }
    }
    
    enum Action: Equatable {
        case huriGanaTapped
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

struct EditableHuriView: View {
    
    let store: StoreOf<EditHuri>
    let fontSize: CGFloat
    
    init(store: StoreOf<EditHuri>, fontsize: CGFloat) {
        self.store = store
        self.fontSize = fontsize
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            if !vs.kanji.isEmpty {
                ZStack {
                    Text(vs.kanji)
                        .font(.system(size: fontSize))
                    Button(vs.gana) {
                        vs.send(.huriGanaTapped)
                    }
                    .font(.system(size: fontSize / 2))
                    .lineLimit(1)
                    .offset(y: -fontSize / 1.2)
                }
            } else {
                Text(vs.gana)
                    .font(.system(size: fontSize))
            }

        }
    }
}

struct EditableHuriView_Previews: PreviewProvider {
    static var previews: some View {
        EditableHuriView(
            store: Store(
                initialState: EditHuri.State(huri: Huri.init("大丈夫⌜だいじょうぶ⌟")),
                reducer: EditHuri()
            ),
            fontsize: 20
        )
    }
}
