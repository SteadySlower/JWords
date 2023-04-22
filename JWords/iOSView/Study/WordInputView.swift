//
//  WordInputView.swift
//  JWords
//
//  Created by JW Moon on 2022/08/06.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct InputWord: ReducerProtocol {
    struct State: Equatable {
        var word: Word?
        var meaningText: String
        var kanjiText: String
        var ganaText: String
        
        init(word: Word) {
            self.word = word
            self.meaningText = word.meaningText
            self.kanjiText = word.kanjiText
            self.ganaText = word.ganaText
        }
        
        init() {
            self.meaningText = ""
            self.kanjiText = ""
            self.ganaText = ""
        }
        
        var pageTitle: String {
            word == nil ? "단어 추가하기" : "단어 수정하기"
        }
        
    }
    
    enum Action: Equatable {
        case updateMeaningText(String)
        case updateKanjiText(String)
        case updateGanaText(String)
        case saveButtonTapped
        case editWordResponse(TaskResult<Word>)
    }
    
    @Dependency(\.wordClient) var wordClient
    private enum EditWordID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateMeaningText(let text):
                state.meaningText = text
                return .none
            case .updateKanjiText(let text):
                state.kanjiText = text
                return .none
            case .updateGanaText(let text):
                state.ganaText = text
                return .none
            case .saveButtonTapped:
                if let word = state.word {
                    let wordInput = WordInput(wordBookID: word.wordBookID,
                                              meaningText: state.meaningText,
                                              meaningImage: nil,
                                              ganaText: state.ganaText,
                                              ganaImage: nil,
                                              kanjiText: state.kanjiText,
                                              kanjiImage: nil)
                    return .task {
                        await .editWordResponse(TaskResult { try await wordClient.edit(word, wordInput) })
                    }.cancellable(id: EditWordID.self)
                }
                return .none
            case .editWordResponse(.success(_)):
                return .none
            case let .editWordResponse(.failure(error)):
                // handle error
                print(error)
                return .none
            }
        }
    }

}



struct WordInputView: View {
    let store: StoreOf<InputWord>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text(vs.pageTitle)
                    .padding()
                TextEditor(text: vs.binding(get: \.meaningText, send: InputWord.Action.updateMeaningText))
                    .border(.black)
                    .padding()
                TextEditor(text: vs.binding(get: \.kanjiText, send: InputWord.Action.updateKanjiText))
                    .border(.black)
                    .padding()
                TextEditor(text: vs.binding(get: \.ganaText, send: InputWord.Action.updateGanaText))
                    .border(.black)
                    .padding()
                Button("저장") {
                    vs.send(.saveButtonTapped)
                }
            }
        }
    }
}


struct WordInputView_Previews: PreviewProvider {
    static var previews: some View {
        WordInputView(
            store: Store(
                initialState: InputWord.State(),
                reducer: InputWord()._printChanges()
            )
        )
    }
}
