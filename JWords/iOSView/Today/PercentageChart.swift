//
//  PercentageChart.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import SwiftUI

struct PercentageChart: View {
    private let percentage: Float
    @State private var displayPercentage: Float = 0.0
    @State private var textPercentange: Float = 0.0
    
    init(percentage: Float) {
        self.percentage = percentage
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
                .fixedSize()
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

struct PercentageChart_Previews: PreviewProvider {
    static var previews: some View {
        PercentageChart(percentage: Float(22/100))
    }
}
