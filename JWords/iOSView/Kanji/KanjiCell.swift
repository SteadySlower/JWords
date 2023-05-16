//
//  KanjiCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/15.
//

import SwiftUI
import ComposableArchitecture

struct StudyKanji: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        let kanji: Kanji
        var meaningText: String = ""
        var isEditing: Bool = false
        
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
        case editButtonTapped
        case updateMeaningText(String)
        case wordButtonTapped
        case inputButtonTapped
        case onKanjiEdited(Kanji)
    }
    
    private let cd = CoreDataClient.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
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
            ZStack {
                HStack {
                    VStack(spacing: 10) {
                        Text(vs.kanji.kanjiText ?? "")
                            .font(.system(size: 40))
                        if vs.isEditing {
                            HStack {
                                TextField("뜻 입력", text: vs.binding(get: \.meaningText, send: StudyKanji.Action.updateMeaningText))
                                    .frame(width: Constants.Size.deviceWidth * 0.3)
                                    .border(.black)
                                    .multilineTextAlignment(.center)
                                Button("입력") { vs.send(.inputButtonTapped) }
                            }
                        } else {
                            Text(vs.kanji.meaningText ?? "???")
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
        }
    }

    
}
