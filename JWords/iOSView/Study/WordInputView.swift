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
        case editWordResponse(TaskResult<StudyState>)
    }
    
    
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
                return .none
            case .editWordResponse(let result):
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
                    
                }
            }
        }
    }
}

extension WordInputView {
    final class ViewModel: ObservableObject {
        let word: Word?
        
        @Published var meaningText: String
        @Published var kanjiText: String
        @Published var ganaText: String
        
        private let wordService: WordService
        
        private let eventPublisher: PassthroughSubject<Event, Never>
        
        init(word: Word?, dependency: ServiceManager, eventPublisher: PassthroughSubject<Event, Never>) {
            self.word = word
            self.meaningText = word?.meaningText ?? ""
            self.kanjiText = word?.kanjiText ?? ""
            self.ganaText = word?.ganaText ?? ""
            self.wordService = dependency.wordService
            self.eventPublisher = eventPublisher
        }
        
        func saveButtonTapped(_ completionHandler: @escaping () -> Void) {
            if let word = word {
                editWord(word) { [weak self] word in
                    self?.eventPublisher.send(WordInputViewEvent.wordEdited(word: word))
                    completionHandler()
                }
            } else {
                addWord()
            }
        }
            
        private func addWord() {
            
        }
        
        private func editWord(_ word: Word, _ completionHandler: @escaping (Word) -> Void) {
            let wordInput = WordInput(wordBookID: word.wordBookID, meaningText: meaningText, meaningImage: nil, ganaText: ganaText, ganaImage: nil, kanjiText: kanjiText, kanjiImage: nil)
            wordService.updateWord(word, wordInput) { word, error in
                //TODO: handle error (in completionHandler as well)
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let word = word else { return }
                completionHandler(word)
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
