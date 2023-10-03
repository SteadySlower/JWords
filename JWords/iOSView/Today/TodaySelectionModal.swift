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
        var wordBooks: [StudySet] = []
        var reviewedBooks: [StudySet]
        var schedules: [String:Schedule]
        var isLoading: Bool = false
        
        init(todayBooks: [StudySet], reviewBooks: [StudySet], reviewedBooks :[StudySet]) {
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
        
        var newSchedule: TodaySchedule {
            getTodaySchedule(schedules, reviewedBooks.map { $0.id })
        }
        
        fileprivate func getTodaySchedule(_ schedule: [String:Schedule], _ reviewedIDs: [String]) -> TodaySchedule {
            let studyIDs = schedule.keys.filter { schedule[$0] == .study }
            let reviewIDs = schedule.keys.filter { schedule[$0] == .review }
            let reviewedIDs = reviewedIDs.filter { schedule[$0, default: .none] == .none }
            return TodaySchedule(studyIDs: studyIDs,
                                  reviewIDs: reviewIDs,
                                  reviewedIDs: reviewedIDs,
                                  createdAt: Date())
        }
    }
    
    let kv = KVStorageClient.shared
    let cd = CoreDataService.shared
    
    enum Action: Equatable {        
        case onAppear
        case studyButtonTapped(StudySet)
        case reviewButtonTapped(StudySet)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let books = try! cd.fetchSets()
                state.wordBooks = sortWordBooksBySchedule(books, schedule: state.schedules)
                return .none
            case let .studyButtonTapped(book):
                state.toggleStudy(book.id)
                return .none
            case let .reviewButtonTapped(book):
                state.toggleReview(book.id)
                return .none
            }
        }
    }
    
    private func sortWordBooksBySchedule(_ wordBooks: [StudySet], schedule: [String:Schedule]) -> [StudySet] {
        return wordBooks.sorted(by: { book1, book2 in
            if schedule[book1.id, default: .none] != .none
                && schedule[book2.id, default: .none] == .none {
                return true
            } else {
                return false
            }
        })
    }

}

struct TodaySelectionModal: View {
    
    let store: StoreOf<TodaySelection>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                Text("학습 혹은 복습할 단어장을 골라주세요.")
                    .font(.system(size: 20))
                    .bold()
                    .padding(.vertical, 10)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(vs.wordBooks, id: \.id) { wordBook in
                            bookCell(wordBook,
                                     vs.schedules[wordBook.id] ?? .none,
                                     { vs.send(.studyButtonTapped(wordBook)) },
                                     { vs.send(.reviewButtonTapped(wordBook)) })
                        }
                    }
                    
                }
            }
            .padding(.horizontal, 10)
            .loadingView(vs.isLoading)
            .onAppear { vs.send(.onAppear) }
        }
    }
}

// MARK: SubViews

extension TodaySelectionModal {
    
    private func bookCell(_ wordBook: StudySet,
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
            .font(.system(size: 24))
            .defaultRectangleBackground()
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
                        todayBooks: [StudySet(index: 0), StudySet(index: 1), StudySet(index: 2)],
                        reviewBooks: [StudySet(index: 3), StudySet(index: 4), StudySet(index: 5)],
                        reviewedBooks: []),
                    reducer: TodaySelection()._printChanges()
                )
            )
        }
    }
}
