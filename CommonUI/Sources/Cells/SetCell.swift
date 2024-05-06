//
//  HomeCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import CommonUI

public struct SetCell: View {
    private let title: String
    private let dayFromToday: Int
    private let dateTextColor: Color
    private let onTapped: () -> Void
    
    public init(title: String, dayFromToday: Int, dateTextColor: Color, onTapped: @escaping () -> Void) {
        self.title = title
        self.dayFromToday = dayFromToday
        self.dateTextColor = dateTextColor
        self.onTapped = onTapped
    }
    
    public var body: some View {
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
    
    private var dateText: String {
        let dayGap = dayFromToday
        return dayGap == 0 ? "今日" : "\(dayGap)日前"
    }
}
