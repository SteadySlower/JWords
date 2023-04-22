//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import ComposableArchitecture

struct TodayList: ReducerProtocol {
    struct State: Equatable {
        var wordBooks: [WordBook] = []
        var todayWordBooks: [WordBook] = []
        var reviewWordBooks: [WordBook] = []
        var onlyFailWords: [Word] = []
        var wordList: WordList.State?
        var isLoading: Bool = false
        var showModal: Bool = false
        
        var showStudyView: Bool {
            wordList != nil
        }
        
    }
    
    enum Action: Equatable {
        case onAppear
        case wordList(action: WordList.Action)
        case listButtonTapped
        case autoAddButtonTapped
        case showStudyView(Bool)
        case onlyFailCellTapped
        case homeCellTapped(WordBook)
    }
    

    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .showStudyView(let showStudyView):
                if !showStudyView { state.wordList = nil }
                return .none
            case .onlyFailCellTapped:
                state.wordList = WordList.State(words: state.onlyFailWords)
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.wordList, action: /Action.wordList(action:)) {
            WordList()
        }
    }

}

struct TodayView: View {
    let store: StoreOf<TodayList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack {
                    NavigationLink(
                        destination: IfLetStore(store.scope(state: \.wordList,
                                                            action: TodayList.Action.wordList(action:))
                                    ) { StudyView(store: $0) },
                       isActive: vs.binding(get: \.showStudyView,
                                            send: TodayList.Action.showStudyView)) { EmptyView() }
                    Text("오늘 학습할 단어")
                    Button {
                        vs.send(.onlyFailCellTapped)
                    } label: {
                        HStack {
                            Text("틀린 \(vs.onlyFailWords.count) 단어만 모아보기")
                            Spacer()
                        }
                        .padding(12)
                    }
                    .border(.gray, width: 1)
                    .frame(height: 50)
                    VStack(spacing: 8) {
                        ForEach(vs.todayWordBooks, id: \.id) { todayBook in
                            HomeCell(wordBook: todayBook) {
                                vs.send(.homeCellTapped(todayBook))
                            }
                        }
                    }
                }
                VStack {
                    Text("오늘 복습할 단어")
                    VStack(spacing: 8) {
                        ForEach(vs.reviewWordBooks, id: \.id) { reviewBook in
                            HomeCell(wordBook: reviewBook) {
                                vs.send(.homeCellTapped(reviewBook))
                            }
                        }
                    }
                }
            }
            .onAppear { vs.send(.onAppear) }
            //        .sheet(isPresented: $showModal, onDismiss: { viewModel.fetchSchedule() }) { TodaySelectionModal(dependency) }
            .toolbar { ToolbarItem {
                HStack {
                    Button("List") { vs.send(.listButtonTapped) }
                    Button("+") { vs.send(.autoAddButtonTapped) }
                }
            }}

        }
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodayView(
                store: Store(
                    initialState: TodayList.State(),
                    reducer: TodayList()._printChanges()
                )
            )
        }
    }
}

extension TodayView {
    final class ViewModel: ObservableObject {
        private var wordBooks: [WordBook] = []
        
        @Published private(set) var todayWordBooks: [WordBook] = []
        @Published private(set) var reviewWordBooks: [WordBook] = []
        @Published private(set) var onlyFailWords: [Word] = []
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        private let wordService: WordService
        
        init(_ dependency: ServiceManager) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
            self.wordService = dependency.wordService
        }
        
        func fetchSchedule() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                if let wordBooks = wordBooks {
                    self.wordBooks = wordBooks
                }
                self.todayService.getTodayBooks { todayBooks, error in
                    if error != nil {
                        return
                    }
                    guard let todayBooks = todayBooks else { return }
                    self.todayWordBooks = self.wordBooks.filter { todayBooks.studyIDs.contains($0.id) }
                    self.reviewWordBooks = self.wordBooks.filter {
                        todayBooks.reviewIDs.contains($0.id) && !todayBooks.reviewedIDs.contains($0.id)
                    }
                    self.fetchOnlyFailWords()
                }
            }
        }
        
        // TODO: handle error
        func autoFetchTodayBooks() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                guard let wordBooks = wordBooks else { return }
                self.todayService.autoUpdateTodayBooks(wordBooks) { _ in
                    self.fetchSchedule()
                }
            }
        }
        
        // TODO: handle error + move logic to service
        func fetchOnlyFailWords() {
            var onlyFails = [Word]()
            let group = DispatchGroup()
            for todayWordBook in todayWordBooks {
                group.enter()
                wordService.getWords(wordBook: todayWordBook) { words, error in
                    if let error = error { print(error); }
                    if let words = words {
                        let onlyFail = words.filter { $0.studyState != .success }
                        onlyFails.append(contentsOf: onlyFail)
                    }
                    group.leave()
                }
            }
            group.notify(queue: .main) {
                self.onlyFailWords = onlyFails
            }
        }
    }
}
