//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct AddWord: ReducerProtocol {

    struct State: Equatable {
        @BindingState var focusedField: Field?
        var book = SelectWordBook.State()
        var meaning = AddMeaning.State()
        var kanji = AddKanji.State()
        var gana = AddGana.State()
        var isLoading = false
        
        var unableToSave: Bool {
            (book.selectedID == nil)
            || meaning.isEmpty
            || (kanji.isEmpty && gana.isEmpty)
            || isLoading
        }
        
        var wordInput: WordInput? {
            guard let wordBookID = book.selectedID else { return nil }
            return WordInput(wordBookID: wordBookID,
                             meaningText: meaning.text.trimmed,
                             meaningImage: meaning.image,
                             ganaText: gana.text.trimmed,
                             ganaImage: gana.image,
                             kanjiText: kanji.text.trimmed,
                             kanjiImage: kanji.image)
        }
        
        mutating func updateTextBySample(_ id: String?) {
            if let sample = meaning.samples.first { $0.id == id } {
                kanji.text = sample.kanjiText
                gana.text = sample.ganaText
            } else {
                kanji.text = ""
                gana.text = ""
            }
        }
        
        mutating func clearFields() {
            meaning.clearField()
            kanji.clearField()
            gana.clearField()
        }
        
        enum Field: Hashable {
            case meaning, kanji, gana
        }
    }
    
    @Dependency(\.wordClient) var wordClient
    @Dependency(\.sampleClient) var sampleClient
    private enum AddWordID {}
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case selectWordBook(action: SelectWordBook.Action)
        case addMeaning(action: AddMeaning.Action)
        case addKanji(action: AddKanji.Action)
        case addGana(action: AddGana.Action)
        case saveButtonTapped
        case addWordResponse(TaskResult<Bool>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .addMeaning(.onTab):
                state.focusedField = .kanji
                return .none
            case let .addMeaning(.updateSelectedID(id)):
                state.updateTextBySample(id)
                return .none
            case let .addKanji(.updateText(text)):
                if state.gana.autoConvert {
                    state.gana.text = text.hiragana
                }
                state.meaning.selectedID = nil
                return .none
            case .addKanji(.onTab):
                state.focusedField = .gana
                return .none
            case .addGana(.onTab):
                state.focusedField = .meaning
                return .none
            case .addGana(.updateText):
                state.meaning.selectedID = nil
                return .none
            case .saveButtonTapped:
                guard let wordInput = state.wordInput else { return .none }
                if let sample = state.meaning.samples.first { $0.id == state.meaning.selectedID } {
                    sampleClient.used(sample)
                } else {
                    sampleClient.add(wordInput)
                }
                state.clearFields()
                return .task {
                    await .addWordResponse(TaskResult { try await wordClient.add(wordInput) })
                }
                .cancellable(id: AddWordID.self)
            case .addWordResponse(.success):
                state.book.onWordAdded()
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.book, action: /Action.selectWordBook(action:)) {
            SelectWordBook()
        }
        Scope(state: \.meaning, action: /Action.addMeaning(action:)) {
            AddMeaning()
        }
        Scope(state: \.kanji, action: /Action.addKanji(action:)) {
            AddKanji()
        }
        Scope(state: \.gana, action: /Action.addGana(action:)) {
            AddGana()
        }
    }

}

struct MacAddWordView: View {
    
    let store: StoreOf<AddWord>
    @FocusState var focusedField: AddWord.State.Field?
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                WordBookPicker(store: store.scope(
                    state: \.book,
                    action: AddWord.Action.selectWordBook(action:))
                )
                MeaningField(store: store.scope(
                    state: \.meaning,
                    action: AddWord.Action.addMeaning(action:))
                )
                .focused($focusedField, equals: .meaning)
                KanjiField(store: store.scope(
                    state: \.kanji,
                    action: AddWord.Action.addKanji(action:))
                )
                .focused($focusedField, equals: .kanji)
                GanaField(store: store.scope(
                    state: \.gana,
                    action: AddWord.Action.addGana(action:))
                )
                .focused($focusedField, equals: .gana)
                if vs.isLoading {
                    ProgressView()
                } else {
                    Button {
                        vs.send(.saveButtonTapped)
                    } label: {
                        Text("저장")
                    }
                    .disabled(vs.unableToSave)
                    .keyboardShortcut(.return, modifiers: [.control])
                }
            }
            .onAppear { vs.send(.onAppear) }
            .synchronize(vs.binding(\.$focusedField), self.$focusedField)
        }

    }
    
}


struct MacAddWordView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddWordView(
            store: Store(
                initialState: AddWord.State(),
                reducer: AddWord()._printChanges()
            )
        )
    }
}
