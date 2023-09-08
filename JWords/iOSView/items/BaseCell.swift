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
    
    var kanjiText: String { unit.kanjiText }
    var meaningText: String { unit.meaningText }
    
    var showKanjiText: Bool {
        switch frontType {
        case .kanji:
            return true
        case .meaning:
            return !isFront
        }
    }
    
    var showMeaningText: Bool {
        switch frontType {
        case .kanji:
            return !isFront
        case .meaning:
            return true
        }
    }
    
    init(unit: StudyUnit,
         frontType: FrontType,
         isFront: Bool = true,
         dragAmount: CGSize = .zero) {
        self.unit = unit
        self.frontType = frontType
        self.isFront = isFront
        self.dragAmount = dragAmount
    }

    var body: some View {
        ZStack {
            swipeGuide
            ZStack {
                Color.cellColor(unit.studyState)
                cellFace
            }
            .offset(dragAmount)
        }
        .frame(width: deviceWidth * 0.9)
        #if os(iOS)
        .onAppear { deviceOrientationChanged() }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in deviceOrientationChanged() }
        #endif
    }
}

extension BaseCell {

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
    
    private var cellFace: some View {
        let frontFontSize: CGFloat = fontSize(of: kanjiText)
        let backFontSize: CGFloat = 25
        
        return VStack {
            if kanjiText.isHurigana {
                HuriganaText(hurigana: kanjiText,
                             fontSize: frontFontSize,
                             hideYomi: isFront,
                             alignment: unit.type == .sentence ? .leading : .center)
                .opacity(showKanjiText ? 1 : 0)
            } else {
                Text(kanjiText)
                    .font(.system(size: frontFontSize))
                    .opacity(showKanjiText ? 1 : 0)
            }
            Text(meaningText)
                .font(.system(size: backFontSize))
                .opacity(showMeaningText ? 1 : 0)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 8)
    }
    
    private func fontSize(of text: String) -> CGFloat {
        if text.count == 1 {
            return 50
        } else if text.count <= 20 {
            return 40
        } else if text.count <= 30 {
            return 35
        } else {
            return 20
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
