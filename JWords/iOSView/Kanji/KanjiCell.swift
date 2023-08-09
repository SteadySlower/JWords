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
        let id: String
        let kanji: Kanji
        var meaningText: String = ""
        var isEditing: Bool = false
        
        var kanjiImage: Data?
        var meaningImage: Data?
        
        var displayMeaning: String {
            if let meaning = kanji.meaningText {
                return !meaning.isEmpty ? meaning : "???"
            } else {
                return "???"
            }
        }
        
        init(kanji: Kanji) {
            self.id = kanji.id
            self.kanji = kanji
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case onKanjiImageDownloaded(TaskResult<Data>)
        case onMeaningImageDownloaded(TaskResult<Data>)
        case editButtonTapped
        case updateMeaningText(String)
        case wordButtonTapped
        case inputButtonTapped
        case cancelEditButtonTapped
        case onKanjiEdited(Kanji)
    }
    
    private let cd = CoreDataClient.shared
    private let ck = CKImageUploader.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                var effects = [EffectPublisher<StudyKanji.Action, Never>]()
                if let kanjiImageID = state.kanji.kanjiImageID {
                    effects.append(.task {
                        await .onKanjiImageDownloaded(
                            TaskResult { try await ck.fetchImage(id: kanjiImageID) }
                        )
                        
                    })
                }
                if let meaningImageID = state.kanji.meaningImageID {
                    effects.append(.task {
                        await .onMeaningImageDownloaded(
                            TaskResult { try await ck.fetchImage(id: meaningImageID) }
                        )
                        
                    })
                }
                return .merge(effects)
            case let .onKanjiImageDownloaded(.success(data)):
                state.kanjiImage = data
                return .none
            case let .onMeaningImageDownloaded(.success(data)):
                state.meaningImage = data
                return .none
            case .editButtonTapped:
                state.isEditing = true
                state.meaningText = state.kanji.meaningText ?? ""
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
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            VStack {
                HStack {
                    VStack(spacing: 10) {
                        Text(vs.kanji.kanjiText ?? "")
                            .font(.system(size: 40))
                        #if os(macOS)
                            .onTapGesture {
                                // TODO: MUST refactor
                                let pasteboard = NSPasteboard.general
                                pasteboard.clearContents()
                                pasteboard.writeObjects([vs.kanji.kanjiText! as NSPasteboardWriting])
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
                                Button("입력") { vs.send(.inputButtonTapped) }
                            }
                        } else {
                            #if os(iOS)
                            if let imageData = vs.meaningImage,
                                let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                            } else if vs.kanji.meaningImageID != nil {
                                ProgressView()
                            } else {
                                Text(vs.kanji.meaningText ?? "???")
                                    .font(.system(size: 20))
                            }
                            #elseif os(macOS)
                            Text(vs.kanji.meaningText ?? "???")
                                .font(.system(size: 20))
                            #endif
                        }
                    }
                }
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        Button("✏️") {
                            vs.send(.editButtonTapped)
                        }
                        .hide(vs.kanji.meaningImageID != nil)
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
        }
    }

    
}
