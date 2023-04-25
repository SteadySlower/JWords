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
        var studyWordBooks: [WordBook] = []
        var reviewWordBooks: [WordBook] = []
        var onlyFailWords: [Word] = []
        var wordList: WordList.State?
        var todaySelection: TodaySelection.State?
        var isLoading: Bool = false
        
        var showStudyView: Bool {
            wordList != nil
        }
        
        var showModal: Bool {
            todaySelection != nil
        }
        
        fileprivate mutating func clear() {
            studyWordBooks = []
            reviewWordBooks = []
            onlyFailWords = []
            wordList = nil
        }
        
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.wordClient) var wordClient
    @Dependency(\.todayClient) var todayClient
    private enum FetchScheduleID {}
    private enum GetOnlyFailID {}
    private enum AutoAddID {}
    
    enum Action: Equatable {
        case onAppear
        case wordList(action: WordList.Action)
        case todaySelection(action: TodaySelection.Action)
        case setSelectionModal(isPresent: Bool)
        case listButtonTapped
        case autoAddButtonTapped
        case showStudyView(Bool)
        case onlyFailCellTapped
        case homeCellTapped(WordBook)
        case scheduleResponse(TaskResult<TodayBooks>)
        case onlyFailResponse(TaskResult<[Word]>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.clear()
                state.isLoading = true
                return .task {
                    await .scheduleResponse(TaskResult { try await getTodayBooks() })
                }
                .cancellable(id: FetchScheduleID.self)
            case let .scheduleResponse(.success(books)):
                state.studyWordBooks = books.study
                state.reviewWordBooks = books.review
                return .task {
                    await .onlyFailResponse(TaskResult { try await getOnlyFailWords(studyBooks: books.study) })
                }
                .cancellable(id: GetOnlyFailID.self)
            case let .onlyFailResponse(.success(onlyFails)):
                state.onlyFailWords = onlyFails
                state.isLoading = false
                return .none
            case .setSelectionModal(let isPresent):
                if !isPresent { state.todaySelection = nil }
                return .none
            case .onlyFailCellTapped:
                state.wordList = WordList.State(words: state.onlyFailWords)
                return .none
            case let .homeCellTapped(wordBook):
                state.wordList = WordList.State(wordBook: wordBook)
                return .none
            case .listButtonTapped:
                state.todaySelection = TodaySelection.State(todayBooks: state.studyWordBooks,
                                                            reviewBooks: state.reviewWordBooks)
                return .none
            case .autoAddButtonTapped:
                state.clear()
                state.isLoading = true
                return .task {
                    let books = try await wordBookClient.wordBooks()
                    try await todayClient.autoUpdateTodayBooks(books)
                    return await .scheduleResponse(TaskResult { try await getTodayBooks() })
                }
                .cancellable(id: AutoAddID.self)
            default:
                return .none
            }
        }
        .ifLet(\.wordList, action: /Action.wordList(action:)) {
            WordList()
        }
        .ifLet(\.todaySelection, action: /Action.todaySelection(action:)) {
            TodaySelection()
        }
    }
    
    private func getTodayBooks() async throws -> TodayBooks {
        return try await withThrowingTaskGroup(of: Any.self, returning: TodayBooks.self) { group in
            var books: [WordBook]?
            var schedule: TodaySchedule?
            group.addTask { try await wordBookClient.wordBooks() }
            group.addTask { try await todayClient.getTodayBooks() }
            
            for try await result in group {
                if let result = result as? [WordBook] {
                    books = result
                    continue
                }
                if let result = result as? TodaySchedule {
                    schedule = result
                    continue
                }
            }
            
            guard let books = books, let schedule = schedule else {
                throw AppError.generic(massage: "Failed to fetch today's schedule")
            }

            return TodayBooks(books: books, schedule: schedule)
        }
    }
    
    private func getOnlyFailWords(studyBooks: [WordBook]) async throws -> [Word] {
        return try await withThrowingTaskGroup(of: [Word].self, returning: [Word].self) { group in
            var result = [Word]()
            
            for studyBook in studyBooks {
                group.addTask { try await wordClient.words(studyBook) }
            }
            
            for try await words in group {
                result.append(contentsOf: words)
            }
            
            return result.filter { $0.studyState != .success }
        }
    }

}

struct TodayView: View {
    let store: StoreOf<TodayList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                if vs.isLoading {
                    ProgressView()
                        .scaleEffect(5)
                }
                ScrollView {
                    VStack {
                        NavigationLink(
                            destination: IfLetStore(store.scope(state: \.wordList,
                                                                action: TodayList.Action.wordList(action:))
                                        ) { StudyView(store: $0) },
                           isActive: vs.binding(get: \.showStudyView,
                                                send: TodayList.Action.showStudyView))
                        { EmptyView() }
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
                        .disabled(vs.isLoading)
                        VStack(spacing: 8) {
                            ForEach(vs.studyWordBooks, id: \.id) { todayBook in
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
            }

            .onAppear { vs.send(.onAppear) }
            .sheet(isPresented: vs.binding(
                get: \.showModal,
                send: TodayList.Action.setSelectionModal(isPresent:))
            ) {
                IfLetStore(self.store.scope(state: \.todaySelection, action: TodayList.Action.todaySelection(action:))) {
                    TodaySelectionModal(store: $0)
                }
            }
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
