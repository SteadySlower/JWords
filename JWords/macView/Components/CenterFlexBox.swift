//
//  CenterFlexBox.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/11.
//

import SwiftUI

struct CenterFlexBox: Layout {
    private var horizontalSpacing: CGFloat
    private var verticalSpacing: CGFloat
    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat? = nil) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing ?? horizontalSpacing
    }
    
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        
        let height = subviews.map { $0.sizeThatFits(proposal).height }.max() ?? 0
        
        var rowWidths = [CGFloat]()
        var currentRowWidth: CGFloat = 0
        subviews.forEach { subview in
            if currentRowWidth + horizontalSpacing + subview.sizeThatFits(proposal).width >= proposal.width ?? 0 {
                rowWidths.append(currentRowWidth)
                currentRowWidth = subview.sizeThatFits(proposal).width
            } else {
                currentRowWidth += horizontalSpacing + subview.sizeThatFits(proposal).width
            }
        }
        rowWidths.append(currentRowWidth)
        
        let rowCount = CGFloat(rowWidths.count)
        return CGSize(width: max(rowWidths.max() ?? 0, proposal.width ?? 0), height: rowCount * height + (rowCount - 1) * verticalSpacing)
    }
    
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        
        let height = subviews.map { $0.dimensions(in: proposal).height }.max() ?? 0
        guard !subviews.isEmpty else { return }
        // 일단 y좌표 최상단에서 시작
        var y = bounds.minY
        var row = [LayoutSubviews.Element]()
        var rowWidth: CGFloat = 0
        
        for subview in subviews {
            // 아직 한 줄이 다 안차면 row에 넣고 continue
            if rowWidth + subview.dimensions(in: proposal).width < bounds.width {
                row.append(subview)
                rowWidth += subview.dimensions(in: proposal).width + horizontalSpacing
                continue
            }
            
            // 한줄이 다 차면 일단 지금 있는 줄 place 시작한다.
            rowWidth -= horizontalSpacing //👉 horizontalSpacing 하나는 빼준다
            // topLeading 기준 x축 출발점
            var x = bounds.minX + (bounds.width - rowWidth) / 2
            
            // row에 저장되어 있는 것 배열 시작
            for sv in row {
                sv.place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(
                        width: sv.dimensions(in: proposal).width,
                        height: sv.dimensions(in: proposal).height
                    )
                )
                x += sv.dimensions(in: proposal).width + horizontalSpacing
            }
            
            row = []
            rowWidth = 0
            y += height + verticalSpacing
            
            row.append(subview)
            rowWidth += subview.dimensions(in: proposal).width + horizontalSpacing
        }
        
        // row에 마저 남은거 배열
        rowWidth -= horizontalSpacing
        var x = bounds.minX + (bounds.width - rowWidth) / 2
        
        for sv in row {
            sv.place(
                at: CGPoint(x: x, y: y),
                anchor: .topLeading,
                proposal: ProposedViewSize(
                    width: sv.dimensions(in: proposal).width,
                    height: sv.dimensions(in: proposal).height
                )
            )
            x += sv.dimensions(in: proposal).width + horizontalSpacing
        }
    }
}
