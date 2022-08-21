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

enum FrontType {
    case meaning
    case kanji
    
    var toggleButtonTitle: String {
        switch self {
        case .meaning:
            return "漢"
        case .kanji:
            return "한"
        }
    }
}

struct StudyView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    @State private var showEditModal: Bool = false
    @State private var showCloseModal: Bool = false
    
    init(wordBook: WordBook) {
        self.viewModel = ViewModel(wordBook: wordBook)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(viewModel.words) { word in
                    WordCell(word: word, frontType: viewModel.frontType, eventPublisher: viewModel.eventPublisher)
                        .frame(width: deviceWidth * 0.9, height: word.hasImage ? 200 : 100)
                }
            }
        }
        .navigationTitle(viewModel.wordBook.title)
        .onAppear {
            viewModel.updateWords()
            resetDeviceWidth()
        }
        .sheet(isPresented: $showCloseModal) { WordBookCloseView(wordBook: viewModel.wordBook) }
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
                    Button(viewModel.frontType.toggleButtonTitle) {
                        viewModel.toggleFrontType()
                    }
                }
            }
        }
        .toolbar() {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("닫기") { showCloseModal = true }
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
                self?.rawWords = words
                self?.filterWords()
            }
        }
        
        func shuffleWords() {
            words.shuffle()
            eventPublisher.send(StudyViewEvent.toFront)
        }
        
        func toggleStudyMode() {
            studyMode = studyMode == .all ? .excludeSuccess : .all
            filterWords()
            eventPublisher.send(StudyViewEvent.toFront)
        }
        
        func toggleFrontType() {
            frontType = frontType == .meaning ? .kanji : .meaning
            filterWords()
            eventPublisher.send(StudyViewEvent.toFront)
        }
        
        func handleEvent(_ event: Event) {
            guard let event = event as? CellEvent else { return }
            switch event {
            case .studyStateUpdate(let word, let state):
                updateStudyState(word: word, state: state)
            }
        }
        
        func updateStudyState(word: Word, state: StudyState) {
            guard let wordBookID = wordBook.id else { return }
            guard let wordID = word.id else { return }
            WordService.updateStudyState(wordBookID: wordBookID, wordID: wordID, newState: state) { [weak self] error in
                // FIXME: handle error
                if let error = error { print(error); return }
                guard let self = self else { return }
                guard let index = self.rawWords.firstIndex(where: { $0.id == wordID }) else { return }
                self.rawWords[index].studyState = state
                // 틀린 단어만 모아볼 때이고 state가 success일 때는 View에서 제거해야하니까 filtering해야 한다. filtering을 해야 한다
                if self.studyMode == .excludeSuccess && state == .success {
                    self.filterWords()
                }
            }
        }
        
        func closeWordBook(completionHandler: @escaping () -> Void) {
            guard let id = wordBook.id else { return }
            WordService.closeWordBook(id) { error in
                if let error = error { print(error); return }
                completionHandler()
            }
        }
        
        private func filterWords() {
            switch studyMode {
            case .all:
                words = rawWords
            case .excludeSuccess:
                words = rawWords
                            .filter { $0.studyState != .success }
            }
        }
    }
}



