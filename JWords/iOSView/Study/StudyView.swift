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
            LazyVStack(spacing: 32) {
                ForEach(0..<viewModel.displays.count, id: \.self) { index in
                    WordCell(wordDisplay: $viewModel.displays[index], eventPublisher: viewModel.eventPublisher)
                        .frame(width: deviceWidth * 0.9, height: viewModel.displays[index].hasImage ? 200 : 100)
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
        .onReceive(viewModel.eventPublisher) { event in
            viewModel.handleEvent(event)
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
        private var words: [Word] = []
        @Published var displays: [WordDisplay] = []
        @Published private(set) var studyMode: StudyMode = .all
        @Published private(set) var frontType: FrontType = .meaning
        private(set) var eventPublisher = PassthroughSubject<Event, Never>()

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
                self?.filterWords()
            }
        }
        
        func shuffleWords() {
            words.shuffle()
            filterWords()
        }
        
        func toggleStudyMode() {
            studyMode = studyMode == .all ? .excludeSuccess : .all
            filterWords()
        }
        
        func handleEvent(_ event: Event) {
            guard let event = event as? CellEvent else { return }
            switch event {
            case .studyStateUpdate(let id, let state):
                updateStudyState(id: id, state: state)
            }
        }
        
        private func updateStudyState(id: String?, state: StudyState) {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: state) { [weak self] error in
                // FIXME: handle error
                if let error = error { print(error); return }
                guard let self = self else { return }
                guard let index = self.words.firstIndex(where: { $0.id == wordID }) else { return }
                self.words[index].studyState = state
                if self.studyMode == .excludeSuccess && state == .success {
                    self.displays = self.displays.filter { $0.word.id != wordID }
                }
            }
        }
        
        private func filterWords() {
            switch studyMode {
            case .all:
                displays = words
                            .map { WordDisplay(wordBook: wordBook, word: $0, frontType: frontType) }
            case .excludeSuccess:
                displays = words
                            .filter { $0.studyState != .success }
                            .map { WordDisplay(wordBook: wordBook, word: $0, frontType: frontType) }
            }
        }
    }
}



