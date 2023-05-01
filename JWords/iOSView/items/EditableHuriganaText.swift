//
//  EditableHuriganaText.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI
import ComposableArchitecture

struct EditHuriganaText: ReducerProtocol {
    struct State: Equatable {
        var huris: IdentifiedArrayOf<EditHuri.State>
        
        init(hurigana: String) {
            self.huris
            = IdentifiedArray(
                uniqueElements: hurigana
                    .split(separator: "`")
                    .map { Huri(String($0)) }
                    .map { EditHuri.State(huri: $0) }
            )
        }
    }
    
    enum Action: Equatable {
        case editHuri(id: UUID, action: EditHuri.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            default:
                return .none
            }
        }
        .forEach(\.huris, action: /Action.editHuri(id:action:)) {
            EditHuri()
        }
    }

}

struct EditableHuriganaText: View {
    let store: StoreOf<EditHuriganaText>
    let fontSize: CGFloat = 20

    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            WrappingHStack(horizontalSpacing: 0, verticalSpacing: fontSize / 2) {
                ForEachStore(
                    self.store.scope(state: \.huris, action: EditHuriganaText.Action.editHuri(id:action:))
                ) {
                    EditableHuriView(store: $0, fontsize: fontSize)
                }
            }
            .padding(.top, fontSize / 2)
        }
    }
}


struct EditableHuriganaText_Previews: PreviewProvider {
    
    static let sampleHurigana = "弟⌜おとうと⌟``さん`全然⌜ぜんぜん⌟``大丈夫⌜だいじょうぶ⌟``です`よ`色々⌜いろいろ⌟``な`こと`が`ある`の`み`間違⌜まちが⌟`い`ない`よ`君⌜きみ⌟``なん`と`か`なる`よ`緊張⌜きんちょう⌟``し`ない`で`進⌜すす⌟`む`よ`なん`だけ`？`"
    
    static var previews: some View {
        EditableHuriganaText(
            store: Store(initialState: EditHuriganaText.State(hurigana: sampleHurigana),
                                          reducer: EditHuriganaText())
        )
    }
}
