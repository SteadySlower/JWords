//
//  TodaySelectionModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI
import Combine
import ComposableArchitecture

enum Schedule: Equatable {
    case none, study, review
}

struct TodaySelection: ReducerProtocol {
    struct State: Equatable {
        var wordBooks: [WordBook] = []
        var reviewedBooks: [WordBook]
        var schedules: [String:Schedule]
        var isLoading: Bool = false
        
        init(todayBooks: [WordBook], reviewBooks: [WordBook], reviewedBooks :[WordBook]) {
            var schedules = [String:Schedule]()
            for book in todayBooks {
                schedules[book.id] = .study
            }
            for book in reviewBooks {
                schedules[book.id] = .review
            }
            self.schedules = schedules
            self.reviewedBooks = reviewedBooks
        }
        
        mutating func toggleStudy(_ id: String) {
            if schedules[id, default: .none] == .study {
                schedules[id, default: .none] = .none
            } else {
                schedules[id, default: .none] = .study
            }
        }
        
        mutating func toggleReview(_ id: String) {
            if schedules[id, default: .none] == .review {
                schedules[id, default: .none] = .none
            } else {
                schedules[id, default: .none] = .review
            }
        }
        
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    @Dependency(\.todayClient) var todayClient
    private enum FetchWordBookID {}
    private enum UpdateTodayID {}
    
    
    enum Action: Equatable {        
        case onAppear
        case wordBookResponse(TaskResult<[WordBook]>)
        case studyButtonTapped(WordBook)
        case reviewButtonTapped(WordBook)
        case okButtonTapped
        case updateTodayResponse(TaskResult<Void>)
        case cancelButtonTapped
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.onAppear, .onAppear):
                return true
            case let (.wordBookResponse(result1), .wordBookResponse(result2)):
                return result1 == result2
            case let (.studyButtonTapped(book1), .studyButtonTapped(book2)):
                return book1.id == book2.id
            case let (.reviewButtonTapped(book1), .reviewButtonTapped(book2)):
                return book1.id == book2.id
            case (.okButtonTapped, .okButtonTapped):
                return true
            case (.updateTodayResponse, .updateTodayResponse):
                return true
            case (.cancelButtonTapped, .cancelButtonTapped):
                return true
            default:
                return false
            }
        }
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .task {
                    await .wordBookResponse(TaskResult { try await wordBookClient.wordBooks() })
                }
                .cancellable(id: FetchWordBookID.self)
            case let .wordBookResponse(.success(books)):
                state.wordBooks = sortWordBooksBySchedule(books, schedule: state.schedules)
                state.isLoading = false
                return .none
            case let .studyButtonTapped(book):
                state.toggleStudy(book.id)
                return .none
            case let .reviewButtonTapped(book):
                state.toggleReview(book.id)
                return .none
            case .okButtonTapped:
                state.isLoading = true
                return .task { [schedule = state.schedules, reviewedIDs = state.reviewedBooks.map { $0.id }] in
                    await .updateTodayResponse(TaskResult {
                        try await updateToday(schedule, reviewedIDs)
                    })
                }
                .cancellable(id: UpdateTodayID.self)
            case .updateTodayResponse(.success()):
                return .none
            default:
                return .none
            }
        }
    }
    
    private func sortWordBooksBySchedule(_ wordBooks: [WordBook], schedule: [String:Schedule]) -> [WordBook] {
        return wordBooks.sorted(by: { book1, book2 in
            if schedule[book1.id, default: .none] != .none
                && schedule[book2.id, default: .none] == .none {
                return true
            } else {
                return false
            }
        })
    }
    
    private func updateToday(_ schedule: [String:Schedule], _ reviewedIDs: [String]) async throws {
        let studyIDs = schedule.keys.filter { schedule[$0] == .study }
        let reviewIDs = schedule.keys.filter { schedule[$0] == .review }
        let reviewedIDs = reviewedIDs.filter { schedule[$0, default: .none] == .none }
        let newTodayBooks = TodaySchedule(studyIDs: studyIDs,
                                          reviewIDs: reviewIDs,
                                          reviewedIDs: reviewedIDs,
                                          createdAt: Date())
        try await todayClient.updateTodayBooks(newTodayBooks)
        
    }

}

struct TodaySelectionModal: View {
    
    let store: StoreOf<TodaySelection>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("학습 혹은 복습할 단어장을 골라주세요.")
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(vs.wordBooks, id: \.id) { wordBook in
                            bookCell(wordBook,
                                     vs.schedules[wordBook.id] ?? .none,
                                     { vs.send(.studyButtonTapped(wordBook)) },
                                     { vs.send(.reviewButtonTapped(wordBook)) })
                        }
                    }
                }
                HStack {
                    Button("취소") { vs.send(.cancelButtonTapped) }
                    Spacer()
                    Button("확인") { vs.send(.okButtonTapped) }
                }
                .padding()
            }
            .padding(10)
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
        }
    }
}

// MARK: SubViews

extension TodaySelectionModal {
    
    private func bookCell(_ wordBook: WordBook,
                          _ schedule: Schedule,
                          _ studyButtonTapped: @escaping () -> Void,
                          _ reviewButtonTapped: @escaping () -> Void) -> some View {
        
        var dateTextColor: Color {
            switch schedule {
            case .none: return .black
            case .study: return .blue
            case .review: return .pink
            }
        }
        
        var dateText: String {
            let dayGap = wordBook.dayFromToday
            return dayGap == 0 ? "今日" : "\(dayGap)日前"
        }
        
        var bookInfo: some View {
            VStack(alignment: .leading) {
                Text(wordBook.title)
                Text(dateText)
                    .foregroundColor(dateTextColor)
            }
        }
        
        var buttons: some View {
            VStack {
                Button("학습") { studyButtonTapped() }
                    .foregroundColor(schedule == .study ? Color.green : Color.black)
                Button("복습") { reviewButtonTapped() }
                    .foregroundColor(schedule == .review ? Color.green : Color.black)
            }
        }
        
        var body: some View {
            HStack {
                bookInfo
                Spacer()
                buttons
            }
            .frame(height: 80)
            .padding(8)
            .border(.gray, width: 1)
            .font(.system(size: 24))
        }
        
        return body
    }
    
}

struct TodaySelectionModal_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodaySelectionModal(
                store: Store(
                    initialState: TodaySelection.State(
                        todayBooks: [WordBook(index: 0), WordBook(index: 1), WordBook(index: 2)],
                        reviewBooks: [WordBook(index: 3), WordBook(index: 4), WordBook(index: 5)],
                        reviewedBooks: []),
                    reducer: TodaySelection()._printChanges()
                )
            )
        }
    }
}
