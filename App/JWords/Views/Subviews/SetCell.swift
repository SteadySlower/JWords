//
//  HomeCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture
import Model

struct SetCell: View {
    private let title: String
    private let schedule: SetSchedule
    private let dayFromToday: Int
    private let onTapped: () -> Void
    private let cellWidth = Constants.Size.deviceWidth * 0.9
    
    init(
        title: String,
        schedule: SetSchedule,
        dayFromToday: Int,
        onTapped: @escaping () -> Void
    ) {
        self.title = title
        self.schedule = schedule
        self.dayFromToday = dayFromToday
        self.onTapped = onTapped
    }
    
    var body: some View {
        ZStack {
            Button {
                onTapped()
            } label: {
                VStack {
                    HStack {
                        Text(title)
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
        .defaultRectangleBackground()
    }
    
    private var dateTextColor: Color {
        switch schedule {
        case .none: return .black
        case .study: return .blue
        case .review: return .pink
        }
    }
    
    private var dateText: String {
        let dayGap = dayFromToday
        return dayGap == 0 ? "今日" : "\(dayGap)日前"
    }
}
