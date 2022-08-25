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
    @Environment(\.scenePhase) var scenePhase
    
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    @State private var showEditModal: Bool = false
    @State private var showCloseModal: Bool = false
    @State private var shouldDismiss: Bool = false
    
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
            viewModel.fetchWords()
            resetDeviceWidth()
        }
        .sheet(isPresented: $showCloseModal, onDismiss: { if shouldDismiss { dismiss() } }) {
            WordBookCloseView(wordBook: viewModel.wordBook, toMoveWords: viewModel.toMoveWords, didClosed: $shouldDismiss)
        }
        .onChange(of: scenePhase) { if $0 != .active { viewModel.updateWordState() } }
        #if os(iOS)
        // TODO: 화면 돌리면 알아서 다시 deviceWidth를 전달해서 cell 크기를 다시 계산한다.
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in resetDeviceWidth() }
        .onReceive(viewModel.eventPublisher) { viewModel.handleEvent($0) }
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
        .toolbar {
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
        
        var toMoveWords: [Word] {
            rawWords.filter { $0.studyState != .success }
        }
        
        func fetchWords() {
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
                
                // rawWords만 수정한다.
                    // words까지 수정하면 전체 list가 re-render되므로 낭비 (어차피 cell color는 WordCell 객체가 처리하니까)
                guard let rawIndex = self.rawWords.firstIndex(where: { $0.id == wordID }) else { return }
                self.rawWords[rawIndex].studyState = state
                
                // 다만 틀린 단어만 모아볼 때이고 state가 success일 때는 View에서 제거해야하니까 filtering해서 words에 반영해야 한다.
                if self.studyMode == .excludeSuccess && state == .success {
                    self.filterWords()
                }
            }
        }
        
        func updateWordState() {
            for i in 0..<words.count {
                guard let newState = rawWords.first(where: { $0.id == words[i].id })?.studyState else { continue }
                words[i].studyState = newState
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



