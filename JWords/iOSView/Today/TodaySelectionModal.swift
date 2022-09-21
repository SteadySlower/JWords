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
            Text("고른 단어장: \(viewModel.selectedID.count)개")
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
        private let isSelected: Bool
        
        init(wordBook: WordBook, viewModel: ViewModel) {
            self.wordBook = wordBook
            self.viewModel = viewModel
            self.isSelected = viewModel.isWordBookSelected(wordBook)
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
                    Image(systemName: "checkmark")
                }
                .frame(height: 80)
                .padding(8)
                .border(.gray, width: 1)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .green : .black)
            }
            .onTapGesture { viewModel.toggleSelected(wordBook.id) }
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
    final class ViewModel: ObservableObject {
        @Published var wordBooks: [WordBook] = []
        @Published var selectedID: [String] = []
        
        private let wordBookService: WordBookService
        private let todayService: TodayService
        
        init(_ dependency: Dependency) {
            self.wordBookService = dependency.wordBookService
            self.todayService = dependency.todayService
        }
        
        func isWordBookSelected(_ wordBook: WordBook) -> Bool {
            selectedID.contains(wordBook.id)
        }
        
        func fetchTodays() {
            wordBookService.getWordBooks { [weak self] wordBooks, error in
                if let error = error { print("디버그: \(error.localizedDescription)"); return }
                if let wordBooks = wordBooks {
                    self?.wordBooks = wordBooks.filter { $0.closed == false }
                }
                self?.todayService.getStudyBooks { idArray, error in
                    self?.selectedID = idArray!
                }
            }
        }
        
        func toggleSelected(_ id: String) {
            if let index = selectedID.firstIndex(of: id) {
                selectedID.remove(at: index)
            } else {
                selectedID.append(id)
            }
        }
        
        func updateToday() {
            todayService.updateStudyBooks(selectedID) { error in
                return
            }
        }
        
        func dateText(of wordBook: WordBook) -> String {
            let dayGap = wordBook.dayFromToday
            return dayGap == 0 ? "今日" : "\(dayGap)日前"
        }
    }
}
