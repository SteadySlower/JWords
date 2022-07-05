//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct StudyView: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var deviceWidth: CGFloat
    
    init(wordBook: WordBook) {
        self.viewModel = ViewModel(wordBook: wordBook)
        self.deviceWidth = Constants.Size.deviceWidth
    }
    
    var body: some View {
        ScrollView {
            VStack {}
            .frame(height: Constants.Size.deviceHeight / 6)
            LazyVStack(spacing: 32) {
                ForEach(viewModel.words) { word in
                    WordCell(wordBook: viewModel.wordBook, word: word)
                        .frame(width: deviceWidth * 0.9, height: word.hasImage ? 200 : 100)
                }
            }
        }
        .navigationTitle(viewModel.wordBook.title)
        .onAppear{ viewModel.updateWords() }
        #if os(iOS)
        // TODO: 화면 돌리면 알아서 다시 deviceWidth를 전달해서 cell 크기를 다시 계산한다.
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            self.deviceWidth = Constants.Size.deviceWidth
        }
        #endif
    }
}

extension StudyView {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        @Published var words: [Word] = []
        
        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
        
        func updateWords() {
            WordService.getWords(wordBookID: wordBook.id!) { [weak self] words, error in
                if let error = error {
                    print("디버그: \(error)")
                }
                guard let words = words else { return }
                self?.words = words
            }
        }
    }
}

