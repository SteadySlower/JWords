//
//  MeaningField.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct AddMeaning: ReducerProtocol {
    
    struct State: Equatable {
        var text = ""
        var autoSearch: Bool = true
        var samples: [Sample] = []
        var selectedID: String? = nil
    }
    
    enum Action: Equatable {
        case updateText(String)
        case updateAutoSearch(Bool)
        case updateSelectedID(String?)
        case onTab
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                if text.hasTab { return .task { .onTab } }
                state.text = text
                return .none
            case .updateAutoSearch(let bool):
                state.autoSearch = bool
                return .none
            case .updateSelectedID(let id):
                state.selectedID = id
                return .none
            case .onTab:
                print("디버그: tab on meaning field")
                return .none
            default:
                return .none
            }
        }
    }
}

struct MeaningField: View {
    
    let store: StoreOf<AddMeaning>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("뜻 입력")
                    .font(.system(size: 20))
                TextEditor(text: vs.binding(
                    get: \.text,
                    send: AddMeaning.Action.updateText))
                    .font(.system(size: 30))
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
                HStack {
                    Toggle("자동 검색",
                           isOn: vs.binding(
                                get: \.autoSearch,
                                send: AddMeaning.Action.updateAutoSearch)
                        )
                        .keyboardShortcut("f", modifiers: [.command])
                    Picker("", selection:
                            vs.binding(
                                 get: \.selectedID,
                                 send: AddMeaning.Action.updateSelectedID)
                    ) {
                        Text(vs.samples.isEmpty ? "검색결과 없음" : "미선택")
                            .tag(nil as String?)
                        ForEach(vs.samples, id: \.id) { sample in
                            Text(sample.description)
                                .tag(sample.id as String?)
                        }
                    }
                }
            }

        }
    }
    
}

struct MeaningField_Previews: PreviewProvider {
    static var previews: some View {
        MeaningField(
            store: Store(
                initialState: AddMeaning.State(),
                reducer: AddMeaning()._printChanges()
            )
        )
    }
}
