//
//  BaseCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/19.
//

import SwiftUI
import Kingfisher

struct BaseCell: View {
    
    private let word: Word
    private let frontType: FrontType
    private let isFront: Bool
    private let dragAmount: CGSize
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    
    init(word: Word,
         frontType: FrontType,
         isFront: Bool = true,
         dragAmount: CGSize = .zero) {
        self.word = word
        self.frontType = frontType
        self.isFront = isFront
        self.dragAmount = dragAmount
    }
    
    var frontText: String {
        switch frontType {
        case .meaning:
            return word.meaningText
        case .kanji:
            return word.kanjiText
        }
    }
    
    var frontImageURLs: [URL] {
        switch frontType {
        case .meaning:
            return [word.meaningImageURL]
                .filter { !$0.isEmpty }
                .compactMap { URL(string: $0) }
        case .kanji:
            return [word.kanjiImageURL]
                .filter { !$0.isEmpty }
                .compactMap { URL(string: $0) }
        }
    }
    
    // frontText를 제외한 두 가지 text에서 빈 text를 제외하고 띄어쓰기
    var backText: String {
        switch frontType {
        case .meaning:
            return [word.ganaText, word.kanjiText]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        case .kanji:
            return [word.ganaText, word.meaningText]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }
    }
    
    var backImageURLs: [URL] {
        switch frontType {
        case .meaning:
            return [word.kanjiImageURL, word.ganaImageURL]
                .filter { !$0.isEmpty }
                .compactMap { URL(string: $0) }
        case .kanji:
            return [word.ganaImageURL, word.meaningImageURL]
                .filter { !$0.isEmpty }
                .compactMap { URL(string: $0) }
        }
    }

    var body: some View {
        ZStack {
            sizeDecisionView
            swipeGuide
            ZStack {
                cellColor
                cellFace(isFront ? frontText : backText,
                         isFront ? frontImageURLs : backImageURLs)
            }
            .offset(dragAmount)
        }
        .frame(width: deviceWidth * 0.9)
        .frame(minHeight: word.hasImage ? 200 : 100)
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
                cellFace(frontText, frontImageURLs)
                Color.white
            }
            ZStack {
                cellFace(backText, backImageURLs)
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
        switch word.studyState {
        case .undefined:
            Color.white
        case .success:
            Color(red: 207/256, green: 240/256, blue: 204/256)
        case .fail:
            Color(red: 253/256, green: 253/256, blue: 150/256)
        }
    }
    
    private func cellFace(_ text: String, _ imageURLs: [URL]) -> some View {
        VStack {
            Text(text)
                .font(.system(size: fontSize(of: text)))
            VStack {
                ForEach(imageURLs, id: \.self) { url in
                    KFImage(url)
                        .resizable()
                        .scaledToFit()
                }
            }
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

