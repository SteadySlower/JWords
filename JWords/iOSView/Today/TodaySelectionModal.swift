//
//  TodaySelectionModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct TodaySelectionModal: View {
    
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showProgressView: Bool = false
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(dependency)
    }
    
    var body: some View {
        ZStack {
            if showProgressView {
                ProgressView()
                    .scaleEffect(5)
            }
            VStack {
                Text("학습 혹은 복습할 단어장을 골라주세요.")
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(viewModel.wordBooks, id: \.id) { wordBook in
                            CheckableCell(wordBook: wordBook, viewModel: viewModel)
                        }
                    }
                }
                HStack {
                    Button("취소") { dismiss() }
                    Spacer()
                    Button("확인") {
                        showProgressView = true
                        viewModel.updateToday {
                            showProgressView = false
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .padding(10)
        }
        .onAppear { viewModel.fetchTodays() }
    }
}

extension TodaySelectionModal {
    private struct CheckableCell: View {
        
        private let wordBook: WordBook
        private let viewModel: ViewModel
        private let schedule: Schedule
        
        init(wordBook: WordBook, viewModel: ViewModel) {
            self.wordBook = wordBook
            self.viewModel = viewModel
            self.schedule = viewModel.schedules[wordBook.id, default: .none]
        }
        
        var body: some View {
            ZStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text(wordBook.title)
                        Text(viewModel.dateText(of: wordBook))
                            .foregroundColor(dateTextColor)
                    }
                    Spacer()
                    VStack {
                        Button("학습") { viewModel.studyButtonTapped(wordBook.id) }
                            .foregroundColor(schedule == .study ? Color.green : Color.black)
                        Button("복습") { viewModel.reviewButtonTapped(wordBook.id) }
                            .foregroundColor(schedule == .review ? Color.green : Color.black)
                    }
                }
                .frame(height: 80)
                .padding(8)
                .border(.gray, width: 1)
                .font(.system(size: 24))
            }
        }
        
        private var dateTextColor: Color {
            switch wordBook.schedule {
            case .none: return .black
            case .study: return .blue
            case .review: return .pink
            }
        }
    }
}

extension TodaySelectionModal {
    enum Schedule {
        case none, study, review
    }
    
    final class ViewModel: ObservableObject {
        @Published var wordBooks: [WordBook] = []
        @Published var schedules = [String : Schedule]()
        
        private var todayBooks: TodayBooks?
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        init(_ dependency: Dependency) {
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
                    self.wordBooks = wordBooks.filter { !$0.closed }
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
            let newTodayBooks = TodayBooksImpl(studyIDs: studyIDs, reviewIDs: reviewIDs, reviewedIDs: reviewedIDs, createdAt: Date())
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
