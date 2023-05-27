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
        var type: UnitType
        var huriText: EditHuriganaText.State
        var kanjiImage: Data?
        var ganaImage: Data?
        var meaningImage: Data?
        
        var overlappingUnit: StudyUnit?
        var overlappingMeaningText: String = ""
        
        var conversionInput: ConversionInput {
            
            let kanjiText = type == .kanji ? word.kanjiText : huriText.hurigana
            
            return ConversionInput(type: type,
                            kanjiText: kanjiText,
                            kanjiImage: kanjiImage,
                            meaningText: word.meaningText,
                            meaningImage: meaningImage,
                            studyState: word.studyState,
                            createdAt: word.createdAt)
        }
        
        init(word: Word) {
            self.id = word.id
            self.word = word
            self.huriText = .init(hurigana: HuriganaConverter.shared.convert(word.kanjiText))
            if word.kanjiText.count == 1 {
                self.type = .kanji
            } else if word.kanjiText.count > 10 {
                self.type = .sentence
            } else if word.hasImage && word.kanjiText.isEmpty {
                self.type = .sentence
            } else {
                self.type = .word
            }
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case imageDownLoaded(TaskResult<Images>)
        case updateType(UnitType)
        case editHuriText(action: EditHuriganaText.Action)
        case moveButtonTapped
        case existing(StudyUnit)
        case updateOverlappingText(String)
        case editAndMoveButtonTapped
        case onMove(ConversionInput)
        case onEditAndMove(StudyUnit, String)
    }
    
    private let cd = CoreDataClient.shared
    
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
                if let exist = try! cd.checkIfExist(state.conversionInput.kanjiText) {
                    state.overlappingUnit = exist
                    state.overlappingMeaningText = exist.meaningText ?? ""
                    return .none
                }
                return .task { [conversionInput = state.conversionInput] in
                    .onMove(conversionInput)
                }
            case .updateOverlappingText(let text):
                state.overlappingMeaningText = text
            case .editAndMoveButtonTapped:
                guard let unit = state.overlappingUnit else { break }
                return .task { [meaningText = state.overlappingMeaningText] in
                    .onEditAndMove(unit, meaningText)
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
                Picker("타입", selection:
                        vs.binding(get: \.type,
                                   send: FirebaseWord.Action.updateType)
                ) {
                    ForEach(UnitType.allCases, id: \.self) { type in
                        Text(type.description)
                    }
                }
                .pickerStyle(.segmented)
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
                } else if !vs.word.kanjiImageURL.isEmpty {
                    ProgressView()
                }
                if let image = vs.ganaImage {
                    HStack {
                        Text("가나 이미지: ")
                        Image(nsImage: NSImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                } else if !vs.word.ganaImageURL.isEmpty {
                    ProgressView()
                }
                if let image = vs.meaningImage {
                    HStack {
                        Text("뜻 이미지: ")
                        Image(nsImage: NSImage(data: image)!)
                            .resizable()
                            .scaledToFit()
                    }
                } else if !vs.word.meaningImageURL.isEmpty {
                    ProgressView()
                }
                if let unit = vs.overlappingUnit {
                    VStack(alignment: .leading) {
                        Text("이미 존재하는 단어입니다.")
                        HStack(alignment: .top) {
                            Text("후리가나: ")
                            HuriganaText(hurigana: unit.kanjiText ?? "", alignment: .leading)
                        }
                        TextEditor(text: vs.binding(
                            get: \.overlappingMeaningText,
                            send: FirebaseWord.Action.updateOverlappingText))
                        Text("한자 이미지 " + "\(unit.kanjiImageID == nil ? "없음" : "있음")")
                        Text("뜻 이미지 " + "\(unit.meaningImageID == nil ? "없음" : "있음")")
                    }
                }
                if vs.overlappingUnit == nil {
                    Button("이동 하기") {
                        vs.send(.moveButtonTapped)
                    }
                } else {
                    Button("수정 및 추가") {
                        vs.send(.editAndMoveButtonTapped)
                    }
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
