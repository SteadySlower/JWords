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
            OnlyFailCell(dependency: dependency)
            VStack(spacing: 8) {
                ForEach(viewModel.todayBooks, id: \.id) { todayBook in
                    HomeCell(wordBook: todayBook, dependency: dependency)
                }
            }
        }
        .onAppear { viewModel.fetchTodayBooks() }
    }
}

extension TodayView {
    private struct OnlyFailCell: View {
        
        private let dependency: Dependency
        
        init(dependency: Dependency) {
            self.dependency = dependency
        }
        
        var body: some View {
            ZStack {
                NavigationLink {
                    StudyView(words: [], dependency: dependency)
                } label: {
                    HStack {
                        Text("틀린 단어 모아보기")
                        Spacer()
                    }
                    .padding(12)
                }
            }
            .border(.gray, width: 1)
            .frame(height: 50)
        }
        
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
