//
//  LeadingFlexBox.swift
//  JWords
//
//  Created by JW Moon on 2023/04/30.
//

import SwiftUI

struct LeadingFlexBox: Layout {
    
    private var horizontalSpacing: CGFloat
    private var verticalSpacing: CGFloat
    
    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        // subview가 없으면 .zero를 리턴
        guard !subviews.isEmpty else { return .zero }

        // subview들의 높이 중에서 최대값을 구한다.
        let height = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0

        // 너비 중에서 최대값을 구하는 과정
        var rowWidths = [CGFloat]() // 각 row의 너비들
        var currentRowWidth: CGFloat = 0 // 현재 너비
        // 모든 subview를 순회하면서 너비를 구한다.
        subviews.forEach { subview in
            // 현재 너비에 subview의 너비를 더했을 때 부모 view 보다 큰 경우 -> 줄 바꿈
            if currentRowWidth + horizontalSpacing + subview.sizeThatFits(proposal).width >= proposal.width ?? 0 {
                rowWidths.append(currentRowWidth) // 현재까지의 너비 기록하고
                currentRowWidth = subview.sizeThatFits(proposal).width // 현재 subview부터 다시 너비 측정
            // 줄바꾸지 않고 너비 누적
            } else {
                currentRowWidth += horizontalSpacing + subview.sizeThatFits(proposal).width
            }
        }
        // 남은 currentRowWidth 배열에 넣기
        rowWidths.append(currentRowWidth)

        let rowCount = CGFloat(rowWidths.count)
        // 너비: row의 너비 중에 가장 큰 값
        // 높이: subview의 높이 * row의 갯수 + 수직 간격 * (row의 갯수 - 1)
        return CGSize(width: max(rowWidths.max() ?? 0, proposal.width ?? 0), height: rowCount * height + (rowCount - 1) * verticalSpacing)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let height = subviews.map { $0.dimensions(in: proposal).height }.max() ?? 0 // subview의 높이 중 최대값
        guard !subviews.isEmpty else { return } // subview가 없으면 리턴
        
        // 첫줄 시작점
        var x = bounds.minX // 부모뷰의 가장 왼쪽
        var y = bounds.minY // 첫 row의 위치
        
        subviews.forEach { subview in
            // 줄바꿈을 하는 경우: (현재 x좌표 + 현재 subview의 너비) > 부모뷰의 오른쪽 끝 x좌표
            if x + subview.dimensions(in: proposal).width > bounds.maxX  {
                x = bounds.minX // 다시 부모뷰의 가장 왼쪽
                y += height + verticalSpacing // 다음 row의 위치
            }
            
            // subview 위치
            subview.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading, // 좌표의 기준 (좌상단)
                proposal: ProposedViewSize(
                    width: subview.dimensions(in: proposal).width,
                    height: subview.dimensions(in: proposal).height
                )
            )
            
            // 다음 subview의 x좌표 = 현재 subview의 x좌표 + 현재 subview의 너비 + 수평 간격
            x += subview.dimensions(in: proposal).width + horizontalSpacing

        }
    }
}
