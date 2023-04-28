//
//  KanjiField.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct AddKanji: ReducerProtocol {
    
    struct State: Equatable {
        var text = ""
        var image: InputImageType?
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    enum Action: Equatable {
        case updateText(String)
        case imageAddButtonTapped
        case imageTapped
        case onTab
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateText(let text):
                if text.hasTab { return .task { .onTab } }
                state.text = text
                return .none
            case .imageAddButtonTapped:
                state.image = pasteBoardClient.fetchImage()
                return .none
            case .imageTapped:
                state.image = nil
                return .none
            case .onTab:
                print("디버그: tab on gana field")
                return .none
            default:
                return .none
            }
        }
    }
}

struct KanjiField: View {
    
    let store: StoreOf<AddKanji>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("한자 입력")
                    .font(.system(size: 20))
                TextEditor(text: vs.binding(
                    get: \.text,
                    send: AddKanji.Action.updateText))
                    .font(.system(size: 30))
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
                if let image = vs.image {
                    Group {
                        #if os(iOS)
                        Image(uiImage: image).resizable()
                        #elseif os(macOS)
                        Image(nsImage: image).resizable()
                        #endif
                    }
                    .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                    .onTapGesture { vs.send(.imageTapped) }
                } else {
                    Button {
                        vs.send(.imageAddButtonTapped)
                    } label: {
                        Text("뜻 이미지")
                    }
                }
            }

        }
    }
    
}

struct KanjiField_Previews: PreviewProvider {
    static var previews: some View {
        KanjiField(
            store: Store(
                initialState: AddKanji.State(),
                reducer: AddKanji()._printChanges()
            )
        )
    }
}


