//
//  TodayView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct TodayView: View {
    @ObservedObject private var viewModel: ViewModel
    
    private let dependency: Dependency
    
    init(_ dependency: Dependency) {
        self.viewModel = ViewModel(dependency.todayService)
        self.dependency = dependency
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(viewModel.todayBooks, id: \.id) { todayBook in
                    HomeCell(wordBook: todayBook, dependency: dependency)
                }
            }
        }
        .navigationTitle("오늘의 단어장")
        .onAppear { viewModel.fetchTodayBooks() }
    }
}

extension TodayView {
    final class ViewModel: ObservableObject {
        @Published private(set) var todayBooks: [WordBook] = []
        private let todayService: TodayService
        
        init(_ todayService: TodayService) {
            self.todayService = todayService
        }
        
        func fetchTodayBooks() {
            todayService.getTodayBooks { [weak self] todayBooks, error in
                if let error = error {
                    print(error)
                    return
                }
                if let todayBooks = todayBooks {
                    self?.todayBooks = todayBooks
                }
            }
        }
    }
}
