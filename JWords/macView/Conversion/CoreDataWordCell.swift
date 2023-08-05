//
//  CoreDataWordCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/05/23.
//

import SwiftUI
import ComposableArchitecture

struct CoreDataWord: ReducerProtocol {
    
    struct Images: Equatable {
        var meaning: Data? = nil
        var kanji: Data? = nil
    }
    
    struct State: Equatable, Identifiable {
        let id: String
        let unit: StudyUnit
        var kanjiImage: Data?
        var meaningImage: Data?

        init(unit: StudyUnit) {
            self.id = unit.id
            self.unit = unit
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case imageDownLoaded(TaskResult<Images>)
    }
    
    private let iu = CKImageUploader.shared
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { [unit = state.unit] in
                    await .imageDownLoaded( TaskResult { try await downloadImages(of: unit) } )
                }
            case let .imageDownLoaded(.success(images)):
                state.kanjiImage = images.kanji
                state.meaningImage = images.meaning
                return .none
            default: break
            }
            return .none
        }
    }
    
    func downloadImages(of unit: StudyUnit) async throws -> Images {
        var result = Images()
        if let kanjiImageID = unit.kanjiImageID {
            result.kanji = try await iu.fetchImage(id: kanjiImageID)
        }
        if let meaningImageID = unit.meaningImageID {
            result.meaning = try await iu.fetchImage(id: meaningImageID)
        }
        return result
    }
}

struct CoreDataWordCell: View {
    
    let store: StoreOf<CoreDataWord>
    let fontSize: CGFloat = 20
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            ZStack {}.frame(height: 50)
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("후리가나: ")
                        .font(.system(size: fontSize))
                    HuriganaText(hurigana: vs.unit.kanjiText ?? "", fontSize: fontSize)
                }
                HStack {
                    Text("뜻: ")
                    Text(vs.unit.meaningText ?? "")
                }
                .font(.system(size: fontSize))
                #if os(macOS)
                if let image = vs.kanjiImage {
                    HStack {
                        Text("한자 이미지: ")
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
                #endif
            }
            .border(.black)
            .onAppear { vs.send(.onAppear) }
        }
    }
}
