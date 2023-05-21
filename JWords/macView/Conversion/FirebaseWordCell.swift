//
//  FirebaseWordList.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct FirebaseWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        let word: Word
        var huriText: EditHuriganaText.State
        
        init(word: Word) {
            self.id = word.id
            self.word = word
            self.huriText = .init(hurigana: HuriganaConverter.shared.convert(word.kanjiText))
        }
    }
    
    enum Action: Equatable {
        case editHuriText(action: EditHuriganaText.Action)
        case moveButtonTapped
        case onMove(TaskResult<ConversionInput>)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .moveButtonTapped:
                return .task { [ state = state ] in
                    let kanjiImage = try await downloadImage(from: state.word.kanjiImageURL)
                    let meaningImage = try await downloadImage(from: state.word.meaningImageURL)
                    return await .onMove( TaskResult {
                        ConversionInput(type: .kanji,
                                        kanjiText: state.huriText.hurigana,
                                        kanjiImage: kanjiImage,
                                        meaningText: state.word.meaningText,
                                        meaningImage: meaningImage)
                    } )
                }
            default: break
            }
            return .none
        }
        Scope(state: \.huriText, action: /Action.editHuriText(action:)) {
            EditHuriganaText()
        }
    }
    
    func downloadImage(from string: String) async throws -> Data? {
        if string.isEmpty { return nil }
        let url  = URL(string: string)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

struct FirebaseWordCell: View {
    
    let store: StoreOf<FirebaseWord>
    let fontSize: CGFloat = 20
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {}.frame(height: 50)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("후리가나: ")
                        .font(.system(size: fontSize))
                    EditableHuriganaText(
                        store: store.scope(
                            state: \.huriText,
                            action: FirebaseWord.Action.editHuriText(action:)),
                        fontsize: fontSize
                    )
                }
                HStack(alignment: .top) {
                    Text("가나: ")
                    Text(vs.word.ganaText)
                }
                .font(.system(size: fontSize))
                HStack {
                    Text("뜻: ")
                    Text(vs.word.meaningText)
                }
                .font(.system(size: fontSize))
                if !vs.word.kanjiImageURL.isEmpty {
                    HStack {
                        Text("한자 이미지: ")
                        KFImage(URL(string: vs.word.kanjiImageURL))
                            .resizable()
                            .scaledToFit()
                    }
                }
                if !vs.word.ganaImageURL.isEmpty {
                    HStack {
                        Text("가나 이미지: ")
                        KFImage(URL(string: vs.word.ganaImageURL))
                            .resizable()
                            .scaledToFit()
                    }
                }
                if !vs.word.meaningImageURL.isEmpty {
                    HStack {
                        Text("뜻 이미지: ")
                        KFImage(URL(string:vs.word.meaningImageURL))
                            .resizable()
                            .scaledToFit()
                    }
                }
                Button("이동 하기") {
                    vs.send(.moveButtonTapped)
                }
            }
            .border(.black)
        }
    }
}

struct FirebaseWordList_Previews: PreviewProvider {
    static var previews: some View {
        FirebaseWordCell(
            store: Store(
                initialState: FirebaseWord.State(word: .init(index: 0)) ,
                reducer: FirebaseWord()._printChanges()
            )
        )
    }
}
