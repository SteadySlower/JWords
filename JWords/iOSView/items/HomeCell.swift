//
//  HomeCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture

struct HomeCell: View {
    private let wordBook: WordBook
    private let cellWidth = Constants.Size.deviceWidth * 0.9
    
    init(wordBook: WordBook) {
        self.wordBook = wordBook
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
                LazyView(
                    StudyView(
                        store: Store(
                            initialState: WordList.State(wordBook: wordBook),
                            reducer: WordList()._printChanges()
                        )
                    )
                )
            } label: {
                VStack {
                    HStack {
                        Text(wordBook.title)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(dateText)
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
        switch wordBook.schedule {
        case .none: return .black
        case .study: return .blue
        case .review: return .pink
        }
    }
    
    private var dateText: String {
        let dayGap = wordBook.dayFromToday
        return dayGap == 0 ? "今日" : "\(dayGap)日前"
    }
}
