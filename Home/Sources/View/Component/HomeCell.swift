//
//  File.swift
//  
//
//  Created by JW Moon on 4/20/24.
//

import SwiftUI
import Model
import CommonUI

struct HomeCell: View {
    private let set: StudySet
    private let onTapped: () -> Void
        
    init(set: StudySet, onTapped: @escaping () -> Void) {
        self.set = set
        self.onTapped = onTapped
    }
    
    var body: some View {
        ZStack {
            Button {
                onTapped()
            } label: {
                VStack {
                    HStack {
                        Text(set.title)
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
        switch set.schedule {
        case .none: return .black
        case .study: return .blue
        case .review: return .pink
        }
    }
    
    private var dateText: String {
        let dayGap = set.dayFromToday
        return dayGap == 0 ? "今日" : "\(dayGap)日前"
    }
}

