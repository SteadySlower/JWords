//
//  KanjiCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture
#if os(macOS)
import Cocoa
#endif

struct StudyKanji: ReducerProtocol {
    struct State: Equatable, Identifiable {
        @BindingState var willEditMeaning: Bool = false
        let id: String
        let kanji: Kanji
        var meaningText: String = ""
        var isEditing: Bool = false
        
        var kanjiImage: Data?
        var meaningImage: Data?
        
        var displayMeaning: String {
            kanji.meaningText.isEmpty ? "???" : kanji.meaningText
        }
        
        init(kanji: Kanji) {
            self.id = kanji.id
            self.kanji = kanji
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case onKanjiImageDownloaded(TaskResult<Data>)
        case onMeaningImageDownloaded(TaskResult<Data>)
        case onKanjiTapped(String)
        case editButtonTapped
        case updateMeaningText(String)
        case wordButtonTapped
        case inputButtonTapped
        case cancelEditButtonTapped
        case onKanjiEdited(Kanji)
    }
    
    private let cd = CoreDataClient.shared
    private let ck = CKImageUploader.shared
    @Dependency(\.pasteBoardClient) var pasteBoardClient
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case let .onKanjiImageDownloaded(.success(data)):
                state.kanjiImage = data
                return .none
            case let .onMeaningImageDownloaded(.success(data)):
                state.meaningImage = data
                return .none
            case .onKanjiTapped(let kanji):
                pasteBoardClient.copyString(kanji)
                return .task { .editButtonTapped }
            case .editButtonTapped:
                state.willEditMeaning = true
                state.isEditing = true
                state.meaningText = state.kanji.meaningText
                return .none
            case .updateMeaningText(let text):
                state.meaningText = text
                return .none
            case .inputButtonTapped:
                guard !state.meaningText.isEmpty else { return .none }
                let edited = try! cd.editKanji(kanji: state.kanji, meaningText: state.meaningText)
                return .task { .onKanjiEdited(edited) }
            case .cancelEditButtonTapped:
                state.isEditing = false
                state.meaningText = ""
                return .none
            default:
                return .none
            }
        }
    }

}

struct KanjiCell: View {
    
    let store: StoreOf<StudyKanji>
    @FocusState private var willEditMeaning: Bool
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                HStack {
                    VStack(spacing: 10) {
                        Text(vs.kanji.kanjiText)
                            .font(.system(size: 40))
                        #if os(macOS)
                            .onTapGesture {
                                vs.send(.onKanjiTapped(vs.kanji.kanjiText))
                            }
                        #endif
                        if vs.isEditing {
                            HStack {
                                Button("취소") { vs.send(.cancelEditButtonTapped)  }
                                    .foregroundColor(.red)
                                TextField("뜻 입력", text: vs.binding(get: \.meaningText, send: StudyKanji.Action.updateMeaningText))
                                    .frame(width: Constants.Size.deviceWidth * 0.3)
                                    .border(.black)
                                    .multilineTextAlignment(.center)
                                    .focused($willEditMeaning)
                                    .onSubmit { vs.send(.inputButtonTapped) }
                                Button("입력") { vs.send(.inputButtonTapped) }
                            }
                        } else {
                            Text(vs.displayMeaning)
                                .font(.system(size: 20))
                        }
                    }
                }
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button("✏️") {
                            vs.send(.editButtonTapped)
                        }
                        Button("단어 보기") {
                            vs.send(.wordButtonTapped)
                        }
                    }
                }
            }
            .frame(width: Constants.Size.deviceWidth * 0.9)
            .padding(.vertical, 5)
            .border(.black)
            .padding(.vertical, 5)
            .onAppear { vs.send(.onAppear) }
            .synchronize(vs.binding(\.$willEditMeaning), self.$willEditMeaning)
        }
    }

    
}
