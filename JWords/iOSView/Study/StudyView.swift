//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import Combine

enum StudyMode: Hashable, CaseIterable {
    case all, excludeSuccess, onlyFail
    
    var pickerText: String {
        switch self {
        case .all: return "전부"
        case .excludeSuccess: return "O제외"
        case .onlyFail: return "X만"
        }
    }
}

enum FrontType: Hashable, CaseIterable {
    case meaning
    case kanji
    
    var pickerText: String {
        switch self {
        case .meaning:
            return "한"
        case .kanji:
            return "漢"
        }
    }
}

struct StudyView: View {
    @ObservedObject private var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) var scenePhase
    
    private let dependency: Dependency
    
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    @State private var showEditModal: Bool = false
    @State private var showCloseModal: Bool = false
    @State private var shouldDismiss: Bool = false
    @State private var showSideBar: Bool = false
    
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
        ZStack {
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(viewModel.words, id: \.id) { word in
                        WordCell(word: word, frontType: viewModel.frontType, eventPublisher: viewModel.eventPublisher, isSelected: viewModel.isSelected(word))
                            .frame(width: deviceWidth * 0.9, height: word.hasImage ? 200 : 100)
                    }
                }
            }
            if showSideBar {
                SettingSideBar(showSideBar: $showSideBar, viewModel: viewModel)
            }
        }
        .navigationTitle(viewModel.wordBook?.title ?? "틀린 단어 모아보기")
        .onAppear {
            viewModel.fetchWords()
            resetDeviceWidth()
        }
        .sheet(isPresented: $showCloseModal, onDismiss: { if shouldDismiss { dismiss() } }) {
            WordBookCloseView(wordBook: viewModel.wordBook!, toMoveWords: viewModel.toMoveWords, didClosed: $shouldDismiss, dependency: dependency)
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
                    Button("설정") {
                        showSideBar = true
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
    private struct SettingSideBar: View {
        
        @Binding var showSideBar: Bool
        @ObservedObject var viewModel: ViewModel
        @GestureState private var dragAmount = CGSize.zero
        
        private var dragGesture: some Gesture {
            DragGesture(minimumDistance: 30, coordinateSpace: .global)
                .onEnded { onEnded($0) }
                .updating($dragAmount) { value, state, _ in
                    if value.translation.width > 0 {
                        state.width = value.translation.width
                    }
                }
        }
        
        var body: some View {
            ZStack(alignment: .trailing) {
                Color.black.opacity(0.5)
                    .onTapGesture { showSideBar = false }
                VStack {
                    Spacer()
                    Picker("", selection: $viewModel.studyMode) {
                        ForEach(StudyMode.allCases, id: \.self) {
                            Text($0.pickerText)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    Picker("", selection: $viewModel.frontType) {
                        ForEach(FrontType.allCases, id: \.self) {
                            Text($0.pickerText)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    Spacer()
                }
                .frame(width: Constants.Size.deviceWidth * 0.7)
                .background { Color.white }
                .offset(x: dragAmount.width)
                .gesture(dragGesture)
            }
            .ignoresSafeArea()
        }
        
        private func onEnded(_ value: DragGesture.Value) {
            if value.translation.width > Constants.Size.deviceWidth * 0.35 {
                showSideBar = false
            }
        }
    }
}

extension StudyView {
    final class ViewModel: ObservableObject {
        let wordBook: WordBook?
        @Published private var _words: [Word] = []
        @Published var studyMode: StudyMode = .all {
            didSet {
                eventPublisher.send(StudyViewEvent.toFront)
            }
        }
        @Published var frontType: FrontType = .kanji {
            didSet {
                eventPublisher.send(StudyViewEvent.toFront)
            }
        }
        
        // 선택해서 이동 기능 관련 variables
        @Published var isSelectionMode: Bool = false
        @Published var selectedWords: [Word] = []
        
        func isSelected(_ word: Word) -> Bool {
            if isSelectionMode {
                return selectedWords.contains(where: { $0.id == word.id })
            } else {
                return false
            }
        }
        
        private(set) var eventPublisher = PassthroughSubject<Event, Never>()
        
        private let wordService: WordService
        
        var words: [Word] {
            switch studyMode {
            case .all: return _words
            case .excludeSuccess: return _words.filter { $0.studyState != .success }
            case .onlyFail: return _words.filter { $0.studyState == .fail }
            }
        }
        
        var toMoveWords: [Word] {
            _words.filter { $0.studyState != .success }
        }
        
        init(wordBook: WordBook, wordService: WordService) {
            self.wordBook = wordBook
            self.wordService = wordService
        }
        
        init(words: [Word], wordService: WordService) {
            self.wordBook = nil
            self._words = words
            self.wordService = wordService
        }
        

        func fetchWords() {
            guard let wordBook = wordBook else { return }
            wordService.getWords(wordBook: wordBook) { [weak self] words, error in
                if let error = error {
                    print("디버그: \(error.localizedDescription)")
                }
                guard let words = words else { return }
                self?._words = words
            }
        }
        
        func shuffleWords() {
            _words.shuffle()
            eventPublisher.send(StudyViewEvent.toFront)
        }
        
        func handleEvent(_ event: Event) {
            guard let event = event as? CellEvent else { return }
            switch event {
            case .studyStateUpdate(let word, let state):
                updateStudyState(word: word, state: state)
            }
        }
        
        private func updateStudyState(word: Word, state: StudyState) {
            wordService.updateStudyState(word: word, newState: state) { [weak self] error in
                // FIXME: handle error
                if let error = error { print(error); return }
                guard let self = self else { return }
                    
                guard let index = self._words.firstIndex(where: { $0.id == word.id }) else { return }
                self._words[index].studyState = state
            }
        }
    }
}



