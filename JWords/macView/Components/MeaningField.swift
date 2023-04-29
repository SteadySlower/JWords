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
        var image: InputImageType?
        var autoSearch: Bool = true
        var samples: [Sample] = []
        var selectedID: String? = nil
        
        var isEmpty: Bool {
            text.isEmpty && image == nil
        }
    }
    
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    @Dependency(\.sampleClient) var sampleClient
    private enum SamplesID {}
    
    enum Action: Equatable {
        case updateText(String)
        case imageAddButtonTapped
        case imageTapped
        case sampleResponse(TaskResult<[Sample]>)
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
            case .imageAddButtonTapped:
                state.image = pasteBoardClient.fetchImage()
                return .none
            case .imageTapped:
                state.image = nil
                return .none
            case .updateAutoSearch(let bool):
                state.autoSearch = bool
                return .none
            case .updateSelectedID(let id):
                state.selectedID = id
                return .none
            case .onTab:
                guard state.autoSearch else { return .none }
                return .task { [meaning = state.text] in
                    await .sampleResponse(TaskResult { try await sampleClient.samplesByMeaning(meaning) })
                }
                .cancellable(id: SamplesID.self)
            case let .sampleResponse(.success(samples)):
                guard !samples.isEmpty else { return .none }
                state.samples = samples
                state.selectedID = samples[0].id
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
            .padding(.horizontal)
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
