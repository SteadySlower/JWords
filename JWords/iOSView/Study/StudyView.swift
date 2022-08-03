//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine

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
                ForEach(0..<viewModel.words.count, id: \.self) { index in
                    WordCell(wordBook: viewModel.wordBook, word: $viewModel.words[index], shuffleProvider: viewModel.shufflePublisher)
                        .frame(width: deviceWidth * 0.9, height: viewModel.words[index].hasImage ? 200 : 100)
                }
            }
        }
        .navigationTitle(viewModel.wordBook.title)
        .onAppear{
            viewModel.updateWords()
            resetDeviceWidth()
        }
        #if os(iOS)
        // TODO: 화면 돌리면 알아서 다시 deviceWidth를 전달해서 cell 크기를 다시 계산한다.
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            resetDeviceWidth()
        }
        .toolbar {
            ToolbarItem {
                Button("랜덤") {
                    viewModel.shuffleWords()
                }
            }
        }
        #endif
    }
    
    private func resetDeviceWidth() {
        self.deviceWidth = Constants.Size.deviceWidth
    }
}

extension StudyView {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook
        @Published var words: [Word] = []
        var shufflePublisher = PassthroughSubject<Void, Never>()

        
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
        
        func shuffleWords() {
            words.shuffle()
            shufflePublisher.send()
        }
    }
}

