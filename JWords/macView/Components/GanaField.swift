//
//  GanaField.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct AddGana: ReducerProtocol {
    
    struct State: Equatable {
        var text = ""
        var image: InputImageType?
        var autoConvert: Bool = true
        
        var isEmpty: Bool {
            text.isEmpty && image == nil
        }
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    enum Action: Equatable {
        case updateText(String)
        case imageAddButtonTapped
        case imageTapped
        case updateAutoConvert(Bool)
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
            case .updateAutoConvert(let bool):
                state.autoConvert = bool
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

struct GanaField: View {
    
    let store: StoreOf<AddGana>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("가나 입력")
                    .font(.system(size: 20))
                TextEditor(text: vs.binding(
                    get: \.text,
                    send: AddGana.Action.updateText))
                    .font(.system(size: 30))
                    .frame(height: Constants.Size.deviceHeight / 8)
                    .padding(.horizontal)
                Toggle("한자 -> 가나 자동 변환",
                       isOn: vs.binding(
                        get: \.autoConvert,
                        send: AddGana.Action.updateAutoConvert))
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

struct GanaField_Previews: PreviewProvider {
    static var previews: some View {
        GanaField(
            store: Store(
                initialState: AddGana.State(),
                reducer: AddGana()._printChanges()
            )
        )
    }
}

