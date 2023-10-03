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
        var studyBook: StudyBook.State?
        var studyUnits: StudyUnits.State?
        var todaySelection: TodaySelection.State?
        var isLoading: Bool = false
        
        var showStudyBookView: Bool {
            studyBook != nil
        }
        
        var showStudyUnitsView: Bool {
            studyUnits != nil
        }
        
        var showModal: Bool {
            todaySelection != nil
        }
        
        var showTutorial: Bool = false
        
        fileprivate mutating func clear() {
            studyWordBooks = []
            reviewWordBooks = []
            onlyFailWords = []
            todayStatus = nil
            studyBook = nil
            studyUnits = nil
            todaySelection = nil
            showTutorial = false
        }
        
        fileprivate mutating func addTodayBooks(todayBooks: TodayBooks) {
            studyWordBooks = todayBooks.study
            reviewWordBooks = todayBooks.review.filter { !reviewedWordBooks.contains($0) }
            reviewedWordBooks = todayBooks.reviewed
        }
        
    }
    
    let kv = KVStorageClient.shared
    let cd = CoreDataService.shared
    
    enum Action: Equatable {
        case onAppear
        case onDisappear
        case studyBook(StudyBook.Action)
        case studyUnits(StudyUnits.Action)
        case todaySelection(action: TodaySelection.Action)
        case setSelectionModal(isPresent: Bool)
        case listButtonTapped
        case clearScheduleButtonTapped
        case showStudyBookView(Bool)
        case showStudyUnitsView(Bool)
        case showTutorial(Bool)
        case todayStatusTapped
        case homeCellTapped(StudySet)
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
                if !isPresent {
                    guard let newSchedule = state.todaySelection?.newSchedule else { return .none }
                    kv.updateSchedule(todaySchedule: newSchedule)
                    state.todaySelection = nil
                    return .task { .onAppear }
                }
                return .none
            case .todayStatusTapped:
                if state.todayStatus == .empty {
                    state.clear()
                    state.isLoading = true
                    let sets = try! cd.fetchSets()
                    kv.autoSetSchedule(sets: sets)
                    fetchSchedule(&state)
                    state.isLoading = false
                    return .none
                } else {
                    state.studyUnits = StudyUnits.State(units: state.onlyFailWords)
                    return .none
                }
            case .homeCellTapped(let set):
                let units = try! cd.fetchUnits(of: set)
                state.studyBook = StudyBook.State(set: set, units: units)
                return .none
            case .listButtonTapped:
                state.todayStatus = nil
                state.todaySelection = TodaySelection.State(todayBooks: state.studyWordBooks,
                                                            reviewBooks: state.reviewWordBooks, reviewedBooks: state.reviewedWordBooks)
                return .none
            case .clearScheduleButtonTapped:
                state.clear()
                state.isLoading = true
                kv.updateSchedule(todaySchedule: .empty)
                fetchSchedule(&state)
                state.isLoading = false
                return .task  { .onAppear }
            case .showTutorial(let show):
                state.showTutorial = show
                return .none
            case .studyBook(let action):
                switch action {
                case .dismiss:
                    state.studyBook = nil
                    return .none
                default: return .none
                }
            default:
                return .none
            }
        }
        .ifLet(\.studyBook, action: /Action.studyBook) {
            StudyBook()
        }
        .ifLet(\.studyUnits, action: /Action.studyUnits) {
            StudyUnits()
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
                        } else {
                            statusLoadingView
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
                .padding(.top, 10)
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyBook,
                                action: TodayList.Action.studyBook)
                            ) { StudyBookView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyBookView,
                                send: TodayList.Action.showStudyBookView))
                { EmptyView() }
                NavigationLink(
                    destination: IfLetStore(
                            store.scope(
                                state: \.studyUnits,
                                action: TodayList.Action.studyUnits)
                            ) { StudyUnitsView(store: $0) },
                    isActive: vs.binding(
                                get: \.showStudyUnitsView,
                                send: TodayList.Action.showStudyUnitsView))
                { EmptyView() }
                NavigationLink(
                    destination: TutorialList(),
                    isActive: vs.binding(
                                get: \.showTutorial,
                                send: TodayList.Action.showTutorial))
                { EmptyView() }
            }
            .withBannerAD()
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
            .navigationTitle("오늘 단어장")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { ToolbarItem {
                HStack {
                    Button {
                        vs.send(.listButtonTapped)
                    } label: {
                        Image(systemName: "list.bullet.rectangle.portrait")
                            .resizable()
                            .foregroundColor(.black)
                    }
                    Button {
                        vs.send(.clearScheduleButtonTapped)
                    } label: {
                        Image(systemName: "eraser")
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
            }}
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        vs.send(.showTutorial(true))
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
            }
            #endif
        }
    }
    
    private var statusLoadingView: some View {
        ZStack {
            Color.white.opacity(0)
            ProgressView()
                .scaleEffect(2)
        }
        .frame(height: 120)
        .defaultRectangleBackground()
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
