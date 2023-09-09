//
//  TodayStatusView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import SwiftUI

struct TodayStatusView: View {
    
    let books: Int
    let total: Int
    let wrong: Int
    let onTapped: () -> Void
    
    var body: some View {
        HStack {
            PercentageChart(percentage: Float(wrong) / Float(total))
            Spacer()
            VStack(alignment: .trailing) {
                Text("단어장 \(books)권의\n모든 단어 \(total)개 중에")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.trailing)
                Text("틀린 단어 \(wrong)개")
                    .font(.system(size: 30))
                    .multilineTextAlignment(.trailing)
                Button {
                    onTapped()
                } label: {
                    Text("모아보기 📖")
                        .font(.system(size: 40))
                }
            }
            .minimumScaleFactor(0.5)
        }
    }
}

struct TodayStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatusView(
            books: 3,
            total: 100,
            wrong: 22
        ) { print("디버그: 모아보기 클릭") }
        .frame(height: 100)
        .padding(.horizontal, 20)
    }
}
