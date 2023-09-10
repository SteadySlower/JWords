//
//  HomeCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture

struct HomeCell: View {
    private let studySet: StudySet
    private let onTapped: () -> Void
    private let cellWidth = Constants.Size.deviceWidth * 0.9
    
    init(studySet: StudySet, onTapped: @escaping () -> Void) {
        self.studySet = studySet
        self.onTapped = onTapped
    }
    
    var body: some View {
        ZStack {
            Button {
                onTapped()
            } label: {
                VStack {
                    HStack {
                        Text(studySet.title)
                            .foregroundColor(.black)
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
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
                .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 5, y: 5)
        )
    }
    
    private var dateTextColor: Color {
        switch studySet.schedule {
        case .none: return .black
        case .study: return .blue
        case .review: return .pink
        }
    }
    
    private var dateText: String {
        let dayGap = studySet.dayFromToday
        return dayGap == 0 ? "今日" : "\(dayGap)日前"
    }
}
