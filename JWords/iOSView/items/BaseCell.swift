//
//  BaseCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/19.
//

import SwiftUI
import Kingfisher

struct BaseCell: View {
    
    private let unit: StudyUnit
    private let frontType: FrontType
    private let isFront: Bool
    private let dragAmount: CGSize
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    
    init(unit: StudyUnit,
         frontType: FrontType,
         isFront: Bool = true,
         dragAmount: CGSize = .zero) {
        self.unit = unit
        self.frontType = frontType
        self.isFront = isFront
        self.dragAmount = dragAmount
    }
    
    var frontText: String? {
        switch frontType {
        case .meaning:
            return unit.kanjiText
        case .kanji:
            return unit.meaningText
        }
    }
    
    // frontText를 제외한 두 가지 text에서 빈 text를 제외하고 띄어쓰기
    var backText: String? {
        switch frontType {
        case .meaning:
            return unit.meaningText
        case .kanji:
            return unit.kanjiText
        }
    }

    var body: some View {
        ZStack {
            sizeDecisionView
            swipeGuide
            ZStack {
                cellColor
                cellFace(isFront ? frontText : backText)
            }
            .offset(dragAmount)
        }
        .frame(width: deviceWidth * 0.9)
//        .frame(minHeight: word.hasImage ? 200 : 100)
        #if os(iOS)
        .onAppear { deviceOrientationChanged() }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in deviceOrientationChanged() }
        #endif
    }
}

extension BaseCell {
    private var sizeDecisionView: some View {
        ZStack {
            ZStack {
                cellFace(frontText)
                Color.white
            }
            ZStack {
                cellFace(backText)
                Color.white
            }
        }
    }
    
    private var swipeGuide: some View {
        HStack {
            Image(systemName: "circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
            Spacer()
            Image(systemName: "x.circle")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.red)
        }
        .background { Color.white }
    }
    
    @ViewBuilder
    private var cellColor: some View {
        switch unit.studyState {
        case .undefined:
            Color.white
        case .success:
            Color(red: 207/256, green: 240/256, blue: 204/256)
        case .fail:
            Color(red: 253/256, green: 253/256, blue: 150/256)
        }
    }
    
    @ViewBuilder
    private func cellFace(_ text: String?) -> some View {
        if let text = text {
            VStack {
                if text.isHurigana {
                    HuriganaText(hurigana: text)
                } else {
                    Text(text)
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private func fontSize(of text: String) -> CGFloat {
        if text.count <= 10 {
            return 45
        } else if text.count <= 30 {
            return 35
        } else {
            return 30
        }
    }
    
    private func deviceOrientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.deviceWidth = Constants.Size.deviceWidth
        }
    }
    
}

struct BaseCell_Previews: PreviewProvider {
    
    static var previews: some View {
        BaseCell(unit: .init(index: 0), frontType: .meaning)
    }
}
