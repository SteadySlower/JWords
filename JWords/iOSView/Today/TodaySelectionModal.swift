//
//  TodaySelectionModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct TodaySelectionModal: View {
    
    @ObservedObject private var viewModel: ViewModel
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(dependency)
    }
    
    var body: some View {
        VStack {
            Text("학습 혹은 복습할 단어장을 골라주세요.")
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(viewModel.wordBooks, id: \.id) { wordBook in
                        CheckableCell(wordBook: wordBook, viewModel: viewModel)
                    }
                }
            }
        }
        .padding(10)
        .onAppear { viewModel.fetchTodays() }
        .onDisappear { viewModel.updateToday() }
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
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        init(_ dependency: Dependency) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
        }
        
        func fetchTodays() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                if let error = error { print("디버그: \(error.localizedDescription)"); return }
                if let wordBooks = wordBooks {
                    self?.wordBooks = wordBooks.filter { $0.closed == false }
                }
                self?.todayService.getStudyBooks { idArray, error in
                    for id in idArray! {
                        self?.schedules[id, default: .none] = .study
                    }
                }
                self?.todayService.getReviewBooks { idArray, error in
                    for id in idArray! {
                        self?.schedules[id, default: .none] = .review
                    }
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
        
        func updateToday() {
            let studyIDs = schedules.keys.filter { schedules[$0] == .study }
            let reviewIDs = schedules.keys.filter { schedules[$0] == .review }
            todayService.updateStudyBooks(studyIDs, completionHandler: { _ in })
            todayService.updateReviewBooks(reviewIDs, completionHandler: { _ in })
        }
        
        func dateText(of wordBook: WordBook) -> String {
            let dayGap = wordBook.dayFromToday
            return dayGap == 0 ? "今日" : "\(dayGap)日前"
        }
    }
}
