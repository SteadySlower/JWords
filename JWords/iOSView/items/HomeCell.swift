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
    
    private let dependency: ServiceManager
    
    init(wordBook: WordBook, dependency: ServiceManager) {
        self.viewModel = ViewModel(wordBook: wordBook)
        self.dependency = dependency
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
//                LazyView(StudyView(wordBook: viewModel.wordBook, dependency: dependency))
            } label: {
                VStack {
                    HStack {
                        Text(viewModel.wordBook.title)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(viewModel.dateText)
                            .foregroundColor(dateTextColor)
                    }
                }
                .padding(12)
            }
        }
        .border(.gray, width: 1)
        .frame(height: 50)
    }
    
    private var dateTextColor: Color {
        switch viewModel.wordBook.schedule {
        case .none: return .black
        case .study: return .blue
        case .review: return .pink
        }
    }
}

extension HomeCell {
    
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
        
        var dateText: String {
            let dayGap = wordBook.dayFromToday
            return dayGap == 0 ? "今日" : "\(dayGap)日前"
        }
    }
}
