//
//  TodayStatusView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import SwiftUI

struct TodayStatusView: View {
    private let percentage: Float
    @State private var displayPercentage: Float = 0.0
    @State private var textPercentange: Float = 0.0
    
    init(total: Int, wrong: Int) {
        self.percentage = Float(wrong) / Float(total)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue, lineWidth: 10)
            Circle()
                .trim(from: 0.0, to: CGFloat(displayPercentage))
                .stroke(Color.red, lineWidth: 10)
                .rotationEffect(.degrees(-90))
            Text("\(String(format: "%.1f", textPercentange * 100))%")
                .font(.body)
        }
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        withAnimation(Animation.easeInOut(duration: 2)) {
            displayPercentage = percentage
        }
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            withAnimation(.linear(duration: 0.1)) {
                textPercentange += (percentage / 20)
                if textPercentange >= percentage {
                    timer.invalidate()
                }
            }
        }
    }
}

struct TodayStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatusView(
            total: 100,
            wrong: 22
        )
    }
}
