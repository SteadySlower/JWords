//
//  TodayCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/09/19.
//

import SwiftUI

struct TodayCell: View {
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
                HStack {
                    Text(viewModel.wordBook.title)
                    Spacer()
                }
                .padding(12)
            }
        }
        .border(.gray, width: 1)
        .frame(height: 50)
    }
}

extension TodayCell {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
    }
}
