//
//  FirebaseWordList.swift
//  JWords
//
//  Created by JW Moon on 2023/05/21.
//

import SwiftUI
import ComposableArchitecture

struct FirebaseWord: ReducerProtocol {
    
    struct Images: Equatable {
        var meaning: Data? = nil
        var kanji: Data? = nil
        var gana: Data? = nil
    }
    
    struct State: Equatable, Identifiable {
        let id: String
        let word: Word
        var huriText: EditHuriganaText.State
        var kanjiImage: Data?
        var ganaImage: Data?
        var meaningImage: Data?
        
        init(word: Word) {
            self.id = word.id
            self.word = word
            self.huriText = .init(hurigana: HuriganaConverter.shared.convert(word.kanjiText))
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case imageDownLoaded(TaskResult<Images>)
        case editHuriText(action: EditHuriganaText.Action)
        case moveButtonTapped
        case onMove(ConversionInput)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { [word = state.word] in
                    await .imageDownLoaded( TaskResult { try await downloadImages(of: word) } )
                }
            case let .imageDownLoaded(.success(images)):
                state.kanjiImage = images.kanji
                state.ganaImage = images.gana
                state.meaningImage = images.meaning
                return .none
            case .moveButtonTapped:
                return .task { [state = state] in
                    .onMove(
                        ConversionInput(type: .kanji,
                                        kanjiText: state.huriText.hurigana,
                                        kanjiImage: state.kanjiImage,
                                        meaningText: state.word.meaningText,
                                        meaningImage: state.meaningImage)
                    )
                }
            default: break
            }
            return .none
        }
        Scope(state: \.huriText, action: /Action.editHuriText(action:)) {
            EditHuriganaText()
        }
    }
    
    func downloadImages(of word: Word) async throws -> Images {
        var result = Images()
        if !word.kanjiImageURL.isEmpty {
            let url = URL(string: word.kanjiImageURL)!
            let (data, _) = try await URLSession.shared.data(from: url)
            result.kanji = data
        }
        if !word.ganaImageURL.isEmpty {
            let url = URL(string: word.ganaImageURL)!
            let (data, _) = try await URLSession.shared.data(from: url)
            result.gana = data
        }
        if !word.meaningImageURL.isEmpty {
            let url = URL(string: word.meaningImageURL)!
            let (data, _) = try await URLSession.shared.data(from: url)
            result.meaning = data
        }
        return result
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
                if let image = vs.kanjiImage {
                    HStack {
                        Text("한자 이미지: ")
                        Image(nsImage: NSImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                }
                if let image = vs.ganaImage {
                    HStack {
                        Text("가나 이미지: ")
                        Image(nsImage: NSImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                }
                if let image = vs.meaningImage {
                    HStack {
                        Text("뜻 이미지: ")
                        Image(nsImage: NSImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                }
                Button("이동 하기") {
                    vs.send(.moveButtonTapped)
                }
            }
            .border(.black)
            .onAppear { vs.send(.onAppear) }
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
