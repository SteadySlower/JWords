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
    
    var frontText: String {
        switch frontType {
        case .kanji:
            return unit.kanjiText ?? ""
        case .meaning:
            return unit.meaningText ?? ""
        }
    }
    
    var backText: String {
        switch frontType {
        case .kanji:
            return unit.meaningText ?? ""
        case .meaning:
            return unit.kanjiText ?? ""
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
                cellColor
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
    
    private var cellFace: some View {
        let frontFontSize = fontSize(of: frontText)
        let backFontSize = fontSize(of: backText)
        
        return VStack {
            if frontText.isHurigana {
                HuriganaText(hurigana: frontText, fontSize: frontFontSize, hideYomi: isFront)
            } else {
                Text(frontText)
                    .font(.system(size: frontFontSize))
            }
            Text(backText)
                .font(.system(size: backFontSize))
                .opacity(isFront ? 0 : 1)
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 8)
    }
    
    private func fontSize(of text: String) -> CGFloat {
        if text.count == 1 {
            return 40
        } else if text.count <= 10 {
            return 30
        } else if text.count <= 10 {
            return 25
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
