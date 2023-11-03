//
//  EditableHuriganaText.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct EditHuriganaText: Reducer {
    struct State: Equatable {
        var huris: [Huri]
        
        init(huris: [Huri]) {
            self.huris = huris
        }
        
        init(hurigana: String) {
            self.huris = hurigana
                .split(separator: String.betweenHurigana)
                .enumerated()
                .map { (index, huriString) in
                    Huri(id: "\(index)\(huriString)", huriString: String(huriString))
                }
        }
        
        var hurigana: String {
            var result = ""
            for huri in huris {
                result += "\(huri.toString)`"
            }
            return result
        }
        
        mutating func updateHuri(_ huri: Huri) {
            guard let index = huris.firstIndex(where: { $0.id == huri.id }) else { return }
            huris[index] = huri
        }
    }
    
    enum Action: Equatable {
        case onGanaUpdated(Huri)
        case onHuriUpdated
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onGanaUpdated(let huri):
                state.updateHuri(huri)
                return .send(.onHuriUpdated)
            default:
                return .none
            }
        }
    }

}

struct EditableHuriganaText: View {
    let store: StoreOf<EditHuriganaText>
    let fontSize: CGFloat
    
    init(store: StoreOf<EditHuriganaText>, fontsize: CGFloat = 20) {
        self.store = store
        self.fontSize = fontsize
    }

    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            FlexBox(horizontalSpacing: 0, verticalSpacing: fontSize / 2, alignment: .leading) {
                ForEach(vs.huris, id: \.id) { huri in
                    EditableHuriUnit(huri: huri, fontSize: fontSize) { vs.send(.onGanaUpdated($0)) }
                }
            }
            .padding(.top, fontSize / 2)
        }
    }
}

#Preview {
    let sampleHurigana = "弟⌜おとうと⌟``さん`全然⌜ぜんぜん⌟``大丈夫⌜だいじょうぶ⌟``です`よ`色々⌜いろいろ⌟``な`こと`が`ある`の`み`間違⌜まちが⌟`い`ない`よ`君⌜きみ⌟``なん`と`か`なる`よ`緊張⌜きんちょう⌟``し`ない`で`進⌜すす⌟`む`よ`なん`だけ`？`"
    
    return EditableHuriganaText(
        store: Store(
            initialState: EditHuriganaText.State(hurigana: sampleHurigana),
            reducer: { EditHuriganaText() })
    )
}
