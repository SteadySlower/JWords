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
                ForEach(0..<viewModel.words.count, id: \.self) { index in
                    WordCell(word: viewModel.words[index], eventPublisher: viewModel.eventPublisher)
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
        private var rawWords: [Word] = []
        @Published var words: [Word] = []
        @Published private(set) var studyMode: StudyMode = .all
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
                self?.rawWords = words
                self?.filterWords()
            }
        }
        
        func shuffleWords() {
            rawWords.shuffle()
            filterWords()
            eventPublisher.send(StudyViewEvent.toFront(id: nil))
        }
        
        func toggleStudyMode() {
            studyMode = studyMode == .all ? .excludeSuccess : .all
            filterWords()
            eventPublisher.send(StudyViewEvent.toFront(id: nil))
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
                guard let index = self?.rawWords.firstIndex(where: { $0.id == wordID }) else { return }
                self?.rawWords[index].studyState = state
                self?.filterWords()
                self?.eventPublisher.send(StudyViewEvent.toFront(id: wordID))
            }
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



