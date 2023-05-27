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
        var units: IdentifiedArrayOf<CoreDataWord.State> = []
    }
    
    enum Action: Equatable {
        case selectStudySet(action: SelectStudySet.Action)
        case selectWordBook(action: SelectWordBook.Action)
        case wordsResponse(TaskResult<[Word]>)
        case unit(id: CoreDataWord.State.ID, action: CoreDataWord.Action)
        case word(id: FirebaseWord.State.ID, action: FirebaseWord.Action)
        case onConverted(TaskResult<StudyUnit>)
    }
    
    private let cd = CoreDataClient.shared
    private let iu = CKImageUploader.shared
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.wordClient) var wordClient
    private enum fetchBooksID {}
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .selectStudySet(let action):
                switch action {
                case .idUpdated:
                    guard let set = state.coredataSet.selectedSet else {
                        state.units = []
                        break
                    }
                    state.units = IdentifiedArrayOf(
                        uniqueElements: try! cd.fetchUnits(of: set).map { CoreDataWord.State(unit: $0) })
                default: break
                }
            case .selectWordBook(let action):
                switch action {
                case .bookUpdated:
                    guard let book = state.firebaseBook.selectedBook else {
                        state.words = []
                        return .none
                    }
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
                    guard let set = state.coredataSet.selectedSet else { break }
                    return .task {
                        await .onConverted( TaskResult { try await cd.convert(input: conversionInput, in: set) } )
                    }
                case let .onEditAndMove(unit, meaning):
                    guard let set = state.coredataSet.selectedSet else { break }
                    return .task {
                        await .onConverted( TaskResult { try await cd.convert(unit: unit, newMeaning: meaning, in: set) } )
                    }
                default: break
                }
            case .onConverted:
                guard let set = state.coredataSet.selectedSet else { break }
                state.units = IdentifiedArrayOf(
                    uniqueElements: try! cd.fetchUnits(of: set).map { CoreDataWord.State(unit: $0) })
            default:
                break
            }
            return .none
        }
        .forEach(\.units, action: /Action.unit(id:action:)) {
            CoreDataWord()
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
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEachStore(
                                    self.store.scope(state: \.units, action: ConversionList.Action.unit(id:action:))
                                  ) {
                                      CoreDataWordCell(store: $0)
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
