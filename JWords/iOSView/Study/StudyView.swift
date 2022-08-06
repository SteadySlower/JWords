//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine

enum StudyMode {
    case all, excludeSuccess
    
    var toggleButtonTitle: String {
        switch self {
        case .all: return "O제외"
        case .excludeSuccess: return "전부"
        }
    }
}

struct StudyView: View {
    @ObservedObject private var viewModel: ViewModel
    @State private var deviceWidth: CGFloat
    @State private var showEditModal: Bool = false
    
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
                    WordCell(wordBook: viewModel.wordBook, word: $viewModel.words[index], delegate: viewModel)
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
                HStack {
                    Button("랜덤") {
                        viewModel.shuffleWords()
                    }
                    Button(viewModel.studyMode.toggleButtonTitle) {
                        viewModel.toggleStudyMode()
                    }
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
        private var rawWords: [Word] = []
        @Published var words: [Word] = []
        @Published private(set) var studyMode: StudyMode = .all
        private(set) var toFrontPublisher = PassthroughSubject<Void, Never>()

        init(wordBook: WordBook) {
            self.wordBook = wordBook
        }
        
        func updateWords() {
            WordService.getWords(wordBookID: wordBook.id!) { [weak self] words, error in
                if let error = error {
                    print("디버그: \(error)")
                }
                guard let words = words else { return }
                self?.rawWords = words
                self?.filterWords()
            }
        }
        
        func shuffleWords() {
            rawWords.shuffle()
            filterWords()
            toFrontPublisher.send()
        }
        
        func toggleStudyMode() {
            studyMode = studyMode == .all ? .excludeSuccess : .all
            filterWords()
            toFrontPublisher.send()
        }
        
        func updateWordState(id: String?, state: StudyState) {
            guard let id = id else { return }
            guard let index = rawWords.firstIndex(where: { $0.id == id }) else { return }
            
        }
        
        private func filterWords() {
            switch studyMode {
            case .all:
                words = rawWords
            case .excludeSuccess:
                words = rawWords.filter { $0.studyState != .success }
            }
        }
    }
}

extension StudyView.ViewModel: WordCellDelegate {
    func didUpdateState(id: String?, state: StudyState) {
        guard let id = id else { return }
        guard let index = rawWords.firstIndex(where: { $0.id == id }) else { return }
        rawWords[index].studyState = state
        filterWords()
    }
    
    func showEditModal(id: String?) {
        
    }
}



