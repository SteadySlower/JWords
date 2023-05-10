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
            todaySelection = nil
        }
        
        fileprivate mutating func addTodayBooks(todayBooks: TodayBooks) {
            studyWordBooks = todayBooks.study
            reviewWordBooks = todayBooks.review
            reviewedWordBooks = todayBooks.reviewed
        }
        
    }
    
    let ud = UserDefaultClient.shared
    let cd = CoreDataClient.shared
    
    enum Action: Equatable {
        case onAppear
        case wordList(action: WordList.Action)
        case todaySelection(action: TodaySelection.Action)
        case setSelectionModal(isPresent: Bool)
        case listButtonTapped
        case autoAddButtonTapped
        case showStudyView(Bool)
        case onlyFailCellTapped
        case homeCellTapped(StudySet)
        case scheduleResponse(TaskResult<TodayBooks>)
        case onlyFailResponse(TaskResult<[Word]>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                state.clear()
                state.isLoading = true
                let todayBooks = TodayBooks(books: try! cd.fetchSets(), schedule: ud.fetchSchedule())
                state.addTodayBooks(todayBooks: todayBooks)
                state.onlyFailWords = todayBooks.study.map { try! cd.fetchUnits(of: $0) }.reduce([], +)
                state.isLoading = false
                return .none
            case .setSelectionModal(let isPresent):
                if !isPresent { state.todaySelection = nil }
                return .none
            case .onlyFailCellTapped:
                state.wordList = WordList.State(units: state.onlyFailWords)
                return .none
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
                ud.authSetSchedule(sets: sets)
                let todayBooks = TodayBooks(books: sets, schedule: ud.fetchSchedule())
                state.addTodayBooks(todayBooks: todayBooks)
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
                if action == WordList.Action.dismiss {
                    state.wordList = nil
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

}

struct TodayView: View {
    let store: StoreOf<TodayList>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ScrollView {
                VStack {
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
                            HomeCell(studySet: todayBook) {
                                vs.send(.homeCellTapped(todayBook))
                            }
                        }
                    }
                }
                VStack {
                    Text("오늘 복습할 단어")
                    VStack(spacing: 8) {
                        ForEach(vs.reviewWordBooks, id: \.id) { reviewBook in
                            HomeCell(studySet: reviewBook) {
                                vs.send(.homeCellTapped(reviewBook))
                            }
                        }
                    }
                }
            }
            .loadingView(vs.isLoading)
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
