//
//  HomeCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct HomeCell: View {
    @ObservedObject private var viewModel: ViewModel
    private let cellWidth = Constants.Size.deviceWidth * 0.9
    
    private let dependency: Dependency
    
    init(wordBook: WordBook, dependency: Dependency) {
        self.viewModel = ViewModel(wordBook: wordBook)
        self.dependency = dependency
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
                StudyView(wordBook: viewModel.wordBook, dependency: dependency)
            } label: {
                VStack {
                    HStack {
                        Text(viewModel.wordBook.title)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(viewModel.dateText)
                    }
                }
                .padding(12)
            }
        }
        .border(.gray, width: 1)
        .frame(height: 50)
    }
}

extension HomeCell {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
        
        var dateText: String {
            let createdAt = wordBook.createdAt.onlyDate
            let now = Date().onlyDate
            let gap = Calendar.current.dateComponents([.day], from: createdAt, to: now).day ?? 0
            return gap == 0 ? "今日" : "\(gap)日前"
        }
    }
}
