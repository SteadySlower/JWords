//
//  EditCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/19.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct EditWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        var word: Word
        let frontType: FrontType
        
        init(word: Word, frontType: FrontType = .kanji) {
            self.id = word.id
            self.word = word
            self.frontType = frontType
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
    }
    
    enum Action: Equatable {
        case cellTapped
    }
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                return .none
            }
        }
    }

}

struct EditCell: View {
    
    let store: StoreOf<EditWord>
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {
                sizeDecisionView(frontText: vs.frontText,
                                 frontImageURLs: vs.frontImageURLs,
                                 backText: vs.backText,
                                 backImageURLs: vs.backImageURLs)
                ZStack {
                    cellColor(vs.word.studyState)
                    cellFace(vs.frontText, vs.frontImageURLs)
                }
            }
            .frame(width: deviceWidth * 0.9)
            .frame(minHeight: vs.word.hasImage ? 200 : 100)
            .editable()
            .onTapGesture { vs.send(.cellTapped) }
            #if os(iOS)
            .onAppear { deviceOrientationChanged() }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in deviceOrientationChanged() }
            #endif
        }
    }
    
}

// MARK: SubViews

extension EditCell {
    
    private func sizeDecisionView(frontText: String,
                                  frontImageURLs: [URL],
                                  backText: String,
                                  backImageURLs: [URL]) -> some View {
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
    
    private func cellColor(_ studyState: StudyState) -> some View {
        Group {
            switch studyState {
            case .undefined:
                Color.white
            case .success:
                Color(red: 207/256, green: 240/256, blue: 204/256)
            case .fail:
                Color(red: 253/256, green: 253/256, blue: 150/256)
            }
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
}

// MARK: View Methods

extension EditCell {
    
    private func deviceOrientationChanged() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.deviceWidth = Constants.Size.deviceWidth
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
}
