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
        var schedules: [String : Schedule]
        var todayBooks: TodaySchedule?
        var isLoading: Bool = false
        
        init(todayBooks: [WordBook], reviewBooks: [WordBook]) {
            var schedules = [String:Schedule]()
            for book in todayBooks {
                schedules[book.id] = .study
            }
            for book in reviewBooks {
                schedules[book.id] = .review
            }
            self.schedules = schedules
        }
        
    }
    
    @Dependency(\.wordBookClient) var wordBookClient
    
    enum Action: Equatable {
        case onAppear
        case wordBookResponse(TaskResult<[WordBook]>)
        case studyButtonTapped(WordBook)
        case reviewButtonTapped(WordBook)
        case cancelButtonTapped
        case okButtonTapped
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .task {
                    await .wordBookResponse(TaskResult { try await wordBookClient.wordBooks() })
                }
            case let .wordBookResponse(.success(books)):
                state.wordBooks = sortWordBooksBySchedule(books, schedule: state.schedules)
                state.isLoading = false
                return .none
            case let .studyButtonTapped(book):
                let id = book.id
                if state.schedules[id, default: .none] == .study {
                    state.schedules[id, default: .none] = .none
                } else {
                    state.schedules[id, default: .none] = .study
                }
                return .none
            case let .reviewButtonTapped(book):
                let id = book.id
                if state.schedules[id, default: .none] == .review {
                    state.schedules[id, default: .none] = .none
                } else {
                    state.schedules[id, default: .none] = .review
                }
                return .none
            default:
                return .none
            }
        }
    }
    
    func sortWordBooksBySchedule(_ wordBooks: [WordBook], schedule: [String:Schedule]) -> [WordBook] {
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
            ZStack {
                if vs.isLoading {
                    progressView
                }
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
            }
            .onAppear { vs.send(.onAppear) }
        }
    }
}

// MARK: SubViews

extension TodaySelectionModal {
    
    private var progressView: some View {
        ProgressView()
            .scaleEffect(5)
    }
    
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
                        reviewBooks: [WordBook(index: 3), WordBook(index: 4), WordBook(index: 5)]),
                    reducer: TodaySelection()._printChanges()
                )
            )
        }
    }
}

extension TodaySelectionModal {
    
    final class ViewModel: ObservableObject {
        @Published var wordBooks: [WordBook] = []
        @Published var schedules = [String : Schedule]()
        
        private var todayBooks: TodaySchedule?
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        init(_ dependency: ServiceManager) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
        }
        
        func fetchTodays() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("디버그: \(error.localizedDescription)")
                    return
                }
                
                if let wordBooks = wordBooks {
                    self.wordBooks = wordBooks
                }
                
                self.todayService.getTodayBooks { todayBooks, error in
                    if let error = error {
                        print("디버그: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let todayBooks = todayBooks else { return }
                    
                    self.todayBooks = todayBooks
                    
                    for studyID in todayBooks.studyIDs {
                        self.schedules[studyID] = .study
                    }
                    
                    for reviewID in todayBooks.reviewIDs {
                        self.schedules[reviewID] = .review
                    }
                    
                    self.sortWordBooksBySchedule()
                }
            }
        }
        
        func studyButtonTapped(_ id: String) {
            if schedules[id, default: .none] == .study {
                schedules[id, default: .none] = .none
            } else {
                schedules[id, default: .none] = .study
            }
        }
        
        func reviewButtonTapped(_ id: String) {
            if schedules[id, default: .none] == .review {
                schedules[id, default: .none] = .none
            } else {
                schedules[id, default: .none] = .review
            }
        }
        
        func updateToday(_ completionHandler: @escaping () -> Void) {
            let studyIDs = schedules.keys.filter { schedules[$0] == .study }
            let reviewIDs = schedules.keys.filter { schedules[$0] == .review }
            let reviewedIDs = todayBooks?.reviewedIDs ?? []
            let newTodayBooks = TodaySchedule(studyIDs: studyIDs, reviewIDs: reviewIDs, reviewedIDs: reviewedIDs, createdAt: Date())
            todayService.updateTodayBooks(newTodayBooks) { _ in
                completionHandler()
            }
        }
        
        func dateText(of wordBook: WordBook) -> String {
            let dayGap = wordBook.dayFromToday
            return dayGap == 0 ? "今日" : "\(dayGap)日前"
        }
        
        func sortWordBooksBySchedule() {
            wordBooks.sort(by: { book1, book2 in
                if schedules[book1.id, default: .none] != .none
                    && schedules[book2.id, default: .none] == .none {
                    return true
                } else {
                    return false
                }
            })
        }
    }
}
