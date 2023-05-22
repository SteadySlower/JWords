//
//  MacStudyView.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct ConversionList: ReducerProtocol {
    struct State: Equatable {
        var coredataSet = SelectStudySet.State(pickerName: "CoreData 단어장")
        var firebaseBook = SelectWordBook.State(pickerName: "Firebase 단어장")
        var words: IdentifiedArrayOf<FirebaseWord.State> = []
        var conversionInput: ConversionInput?
    }
    
    enum Action: Equatable {
        case selectStudySet(action: SelectStudySet.Action)
        case selectWordBook(action: SelectWordBook.Action)
        case wordsResponse(TaskResult<[Word]>)
        case word(id: FirebaseWord.State.ID, action: FirebaseWord.Action)
    }
    
    private let cd = CoreDataClient.shared
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.wordClient) var wordClient
    private enum fetchBooksID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectWordBook(let action):
                switch action {
                case .bookUpdated:
                    guard let book = state.firebaseBook.selectedBook else { return .none }
                    return .task {
                        await .wordsResponse( TaskResult { try await wordClient.words(book) } )
                    }
                default: break
                }
            case let .wordsResponse(.success(words)):
                state.words = IdentifiedArrayOf(
                    uniqueElements: words.map {
                        FirebaseWord.State(word: $0)
                    })
            case .word(_, let action):
                switch action {
                case let .onMove(conversionInput):
                    state.conversionInput = conversionInput
                default: break
                }
            default:
                break
            }
            return .none
        }
        .forEach(\.words, action: /Action.word(id:action:)) {
            FirebaseWord()
        }
        Scope(state: \.coredataSet, action: /Action.selectStudySet(action:)) {
            SelectStudySet()
        }
        Scope(state: \.firebaseBook, action: /Action.selectWordBook(action:)) {
            SelectWordBook()
        }
    }
    
}

struct ConversionView: View {
    
    let store: StoreOf<ConversionList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                HStack {
                    VStack {
                        StudySetPicker(store: store.scope(
                            state: \.coredataSet,
                            action: ConversionList.Action.selectStudySet(action:))
                        )
                        if let input = vs.conversionInput {
                            VStack(alignment: .leading) {
                                Text("한자: \(input.kanjiText)")
                                Text("뜻: \(input.meaningText)")
                                if let kanjiImage = input.kanjiImage {
                                    VStack(alignment: .leading) {
                                        Text("한자 이미지")
                                        Image(nsImage: NSImage(data: kanjiImage)!)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                if let meaningImage = input.meaningImage {
                                    VStack(alignment: .leading) {
                                        Text("뜻 이미지")
                                        Image(nsImage: NSImage(data: meaningImage)!)
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                            }
                        }
                    }
                    VStack {
                        WordBookPicker(store: store.scope(
                            state: \.firebaseBook,
                            action: ConversionList.Action.selectWordBook(action:))
                        )
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEachStore(
                                    self.store.scope(state: \.words, action: ConversionList.Action.word(id:action:))
                                  ) {
                                      FirebaseWordCell(store: $0)
                                  }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct MacStudyView_Previews: PreviewProvider {
    static var previews: some View {
        ConversionView(
            store: Store(
                initialState: ConversionList.State(),
                reducer: ConversionList()._printChanges()
            )
        )
    }
}
