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
    
    init(wordBook: WordBook) {
        self.viewModel = ViewModel(wordBook: wordBook)
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
                StudyView(wordBook: viewModel.wordBook)
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

extension HomeCell {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
    }
}
