//
//  TodayStatusView.swift
//  JWords
//
//  Created by JW Moon on 2023/09/09.
//

import SwiftUI

struct TodayStatus: Equatable {
    let books: Int
    let total: Int
    let wrong: Int
    
    static let empty: Self = .init(books: 0, total: 0, wrong: 0)
}

struct TodayStatusView: View {
    
    private let books: Int
    private let total: Int
    private let wrong: Int
    private let onTapped: () -> Void
    
    init(status: TodayStatus, onTapped: @escaping () -> Void) {
        self.books = status.books
        self.total = status.total
        self.wrong = status.wrong
        self.onTapped = onTapped
    }
    
    var body: some View {
        if books <= 0 {
            emptyView
        } else {
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
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray, lineWidth: 1)
                    .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 5, y: 5)
            )
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            Text("오늘 학습할 단어장이 아직 없습니다📚")
                .font(.system(size: 30))
                .lineLimit(1)
            Button {
                onTapped()
            } label: {
                Text("📚 여기를 눌러 자동으로 추가해주세요.")
                    .font(.system(size: 30))
                    .lineLimit(1)
            }
        }
        .minimumScaleFactor(0.5)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
                .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 5, y: 5)
        )
    }
}

struct TodayStatusView_Previews: PreviewProvider {
    static var previews: some View {
        TodayStatusView(
            status: TodayStatus(
                books: 3,
                total: 100,
                wrong: 22)) { print("디버그: 모아보기 Tapped") }
        .frame(height: 100)
        .padding(.horizontal, 20)
        TodayStatusView(
            status: .empty) { print("자동 추가 Tapped") }
        .frame(height: 100)
        .padding(.horizontal, 20)
        .previewDisplayName("No books")
    }
}
