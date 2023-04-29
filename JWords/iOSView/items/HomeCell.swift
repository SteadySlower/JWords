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
    private let onTapped: () -> Void
    private let cellWidth = Constants.Size.deviceWidth * 0.9
    
    init(wordBook: WordBook, onTapped: @escaping () -> Void) {
        self.wordBook = wordBook
        self.onTapped = onTapped
    }
    
    var body: some View {
        ZStack {
            Button {
                onTapped()
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
