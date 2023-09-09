//
//  TodayStatusView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import SwiftUI

struct TodayStatusView: View {
    private let percentage: Float
    
    init(total: Int, wrong: Int) {
        self.percentage = Float(wrong) / Float(total)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue, lineWidth: 10)
            Circle()
                .trim(from: 0.0, to: CGFloat(percentage))
                .stroke(Color.red, lineWidth: 10)
                .rotationEffect(.degrees(-90))
            Text("\(String(format: "%.2f", percentage * 100))%")
                .font(.body)
        }
    }
}

struct TodayStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatusView(
            total: 134,
            wrong: 80
        )
    }
}
