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
    
    mutating func toggle() {
        self = self == .all ? .excludeSuccess : .all
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
    @State private var studyMode: StudyMode = .all
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    private let dependency: Dependency
    
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    @State private var showEditModal: Bool = false
    @State private var showCloseModal: Bool = false
    @State private var shouldDismiss: Bool = false
    
    init(wordBook: WordBook, dependency: Dependency) {
        self.viewModel = ViewModel(wordBook: wordBook, wordService: dependency.wordService)
        self.dependency = dependency
    }
    
    // 틀린 단어 모아보기용
    init(words: [Word], dependency: Dependency) {
        self.viewModel = ViewModel(words: words, wordService: dependency.wordService)
        self.dependency = dependency
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(studyMode == .all ? viewModel.words : viewModel.onlyFail, id: \.id) { word in
                    WordCell(word: word, frontType: viewModel.frontType, eventPublisher: viewModel.eventPublisher)
                        .frame(width: deviceWidth * 0.9, height: word.hasImage ? 200 : 100)
                }
            }
        }
        .navigationTitle(viewModel.wordBook?.title ?? "틀린 단어 모아보기")
        .onAppear {
            viewModel.fetchWords()
            resetDeviceWidth()
        }
        .sheet(isPresented: $showCloseModal, onDismiss: { if shouldDismiss { dismiss() } }) {
            WordBookCloseView(wordBook: viewModel.wordBook!, toMoveWords: viewModel.onlyFail, didClosed: $shouldDismiss, dependency: dependency)
        }
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
                    Button(studyMode.toggleButtonTitle) {
                        studyMode.toggle()
                    }
                    Button(viewModel.frontType.toggleButtonTitle) {
                        viewModel.toggleFrontType()
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("마감") { showCloseModal = true }
                    .disabled(viewModel.wordBook == nil)
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
        let wordBook: WordBook?
        @Published var words: [Word] = []
        @Published private(set) var frontType: FrontType = .kanji
        private(set) var eventPublisher = PassthroughSubject<Event, Never>()
        
        private let wordService: WordService
        
        var onlyFail: [Word] {
            words.filter { $0.studyState != .success }
        }

        init(wordBook: WordBook, wordService: WordService) {
            self.wordBook = wordBook
            self.wordService = wordService
        }
        
        init(words: [Word], wordService: WordService) {
            self.wordBook = nil
            self.words = words
            self.wordService = wordService
        }
        

        func fetchWords() {
            guard let wordBook = wordBook else { return }
            wordService.getWords(wordBook: wordBook) { [weak self] words, error in
                if let error = error {
                    print("디버그: \(error.localizedDescription)")
                }
                guard let words = words else { return }
                self?.words = words
            }
        }
        
        func shuffleWords() {
            words.shuffle()
            eventPublisher.send(StudyViewEvent.toFront)
        }
        
        func toggleFrontType() {
            frontType = frontType == .meaning ? .kanji : .meaning
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
            wordService.updateStudyState(word: word, newState: state) { [weak self] error in
                // FIXME: handle error
                if let error = error { print(error); return }
                guard let self = self else { return }
                    
                guard let index = self.words.firstIndex(where: { $0.id == word.id }) else { return }
                self.words[index].studyState = state
            }
        }
    }
}



