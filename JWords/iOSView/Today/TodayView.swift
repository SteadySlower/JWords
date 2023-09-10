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
        var studyWordBooks: [StudySet] = []
        var reviewWordBooks: [StudySet] = []
        var reviewedWordBooks: [StudySet] = []
        var onlyFailWords: [StudyUnit] = []
        var todayStatus: TodayStatus?
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
            todayStatus = nil
            wordList = nil
            todaySelection = nil
        }
        
        fileprivate mutating func addTodayBooks(todayBooks: TodayBooks) {
            studyWordBooks = todayBooks.study
            reviewWordBooks = todayBooks.review.filter { !reviewedWordBooks.contains($0) }
            reviewedWordBooks = todayBooks.reviewed
        }
        
    }
    
    let kv = KVStorageClient.shared
    let cd = CoreDataClient.shared
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case wordList(action: WordList.Action)
        case todaySelection(action: TodaySelection.Action)
        case setSelectionModal(isPresent: Bool)
        case listButtonTapped
        case autoAddButtonTapped
        case showStudyView(Bool)
        case todayStatusTapped
        case homeCellTapped(StudySet)
        case scheduleResponse(TaskResult<TodayBooks>)
        case onlyFailResponse(TaskResult<[Word]>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                fetchSchedule(&state)
                return .none
            case .onDisappear:
                state.todayStatus = nil
                return .none
            case .setSelectionModal(let isPresent):
                if !isPresent { state.todaySelection = nil }
                return .none
            case .todayStatusTapped:
                if state.todayStatus == .empty {
                    return .task { .autoAddButtonTapped }
                } else {
                    state.wordList = WordList.State(units: state.onlyFailWords)
                    return .none
                }
            case let .homeCellTapped(wordBook):
                state.wordList = WordList.State(set: wordBook)
                return .none
            case .listButtonTapped:
                state.todaySelection = TodaySelection.State(todayBooks: state.studyWordBooks,
                                                            reviewBooks: state.reviewWordBooks, reviewedBooks: state.reviewedWordBooks)
                return .none
            case .autoAddButtonTapped:
                state.clear()
                state.isLoading = true
                let sets = try! cd.fetchSets()
                kv.autoSetSchedule(sets: sets)
                fetchSchedule(&state)
                state.isLoading = false
                return .none
            case let .todaySelection(action):
                switch action {
                case .okButtonTapped:
                    state.todaySelection = nil
                    return .task { .onAppear }
                case .cancelButtonTapped:
                    state.todaySelection = nil
                    return .none
                default:
                    return .none
                }
            case .wordList(let action):
                switch action  {
                case .onWordsMoved(let reviewed):
                    kv.addReviewedSet(reviewed: reviewed)
                case .dismiss:
                    state.wordList = nil
                default:
                    break
                }
                return .none
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
    
    private func fetchSchedule(_ state: inout TodayList.State) {
        state.isLoading = true
        state.clear()
        let todayBooks = TodayBooks(books: try! cd.fetchSets(), schedule: kv.fetchSchedule())
        state.addTodayBooks(todayBooks: todayBooks)
        let todayWords = todayBooks.study
            .map { try! cd.fetchUnits(of: $0) }
            .reduce([], +)
        state.onlyFailWords = todayWords
                    .filter { $0.studyState != .success }
                    .removeOverlapping()
                    .sorted(by: { $0.createdAt < $1.createdAt })
        state.todayStatus = .init(
            books: todayBooks.study.count,
            total: todayWords.count,
            wrong: state.onlyFailWords.count)
        state.isLoading = false
    }

}

struct TodayView: View {
    let store: StoreOf<TodayList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 20) {
                        Text("공부 단어장")
                            .font(.title)
                            .trailingAlignment()
                        if let todayStatus = vs.todayStatus {
                            TodayStatusView(status: todayStatus) {
                                vs.send(.todayStatusTapped)
                            }
                            .frame(height: 120)
                        }
                        VStack(spacing: 8) {
                            ForEach(vs.studyWordBooks, id: \.id) { todayBook in
                                HomeCell(studySet: todayBook) {
                                    vs.send(.homeCellTapped(todayBook))
                                }
                            }
                        }
                    }
                    VStack(spacing: 20) {
                        Text("복습 단어장")
                            .font(.title)
                            .trailingAlignment()
                        VStack(spacing: 8) {
                            ForEach(vs.reviewWordBooks, id: \.id) { reviewBook in
                                HomeCell(studySet: reviewBook) {
                                    vs.send(.homeCellTapped(reviewBook))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.wordList,
                                action: TodayList.Action.wordList(action:))
                            ) { StudyView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyView,
                                send: TodayList.Action.showStudyView))
                { EmptyView() }
            }
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
            .onDisappear { vs.send(.onDisappear) }
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
