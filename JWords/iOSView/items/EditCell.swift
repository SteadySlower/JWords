//
//  EditCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/19.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct EditWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        var word: Word
        let frontType: FrontType
        
        init(word: Word, frontType: FrontType = .kanji) {
            self.id = word.id
            self.word = word
            self.frontType = frontType
        }
        
    }
    
    enum Action: Equatable {
        case cellTapped
    }
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                return .none
            }
        }
    }

}

struct EditCell: View {
    
    let store: StoreOf<EditWord>
    @State private var deviceWidth: CGFloat = Constants.Size.deviceWidth
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            BaseCell(word: vs.word,
                     frontType: vs.frontType)
                .overlay(
                    Image(systemName: "pencil")
                        .resizable()
                        .foregroundColor(.green)
                        .opacity(0.5)
                        .scaledToFit()
                        .padding()
                )
                .onTapGesture { vs.send(.cellTapped) }
        }
    }
    
}
