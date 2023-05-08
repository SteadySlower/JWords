//
//  SelectionCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/20.
//

import SwiftUI
import Kingfisher
import Combine
import ComposableArchitecture

struct SelectionWord: ReducerProtocol {
    struct State: Equatable, Identifiable {
        let id: String
        let word: Word
        let frontType: FrontType
        var isSelected: Bool
        
        init(word: Word, frontType: FrontType = .kanji) {
            self.id = word.id
            self.word = word
            self.frontType = frontType
            self.isSelected = false
        }
        
    }
    
    enum Action: Equatable {
        case cellTapped
    }
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cellTapped:
                state.isSelected.toggle()
                return .none
            }
        }
    }

}

struct SelectionCell: View {
    
    let store: StoreOf<SelectionWord>
    @State private var dashPhase: CGFloat = 0
    private let selectedColor: Color = Color.blue.opacity(0.2)
    private let unselectedColor: Color = Color.gray.opacity(0.2)
    
    // MARK: Body
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
//            BaseCell(word: vs.word,
//                     frontType: vs.frontType)
//                .overlay { vs.isSelected ? AnyView(selectedOverlay) : AnyView(unselectedOverlay) }
//                .onTapGesture { vs.send(.cellTapped) }
        }
    }
    
}

extension SelectionCell {
    
    private var selectedOverlay: some View {
        selectedColor
            .mask(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 5,
                                               lineCap: .round,
                                               dash: [10, 10],
                                               dashPhase: dashPhase))
                    .animation(.linear.repeatForever(autoreverses: false).speed(1),
                               value: dashPhase)
                    .onAppear { dashPhase = -20 }
            )
    }
    
    private var unselectedOverlay: some View {
        unselectedColor
            .mask (
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 5,
                                               lineCap: .round,
                                               dash: [10, 10],
                                               dashPhase: dashPhase))
                    .onAppear { dashPhase = 0 }
            )
    }
    
}

struct SelectionCell_Previews: PreviewProvider {
    static var previews: some View {
        SelectionCell(
            store: Store(
                initialState: SelectionWord.State(word: Word()),
                reducer: SelectionWord()._printChanges()
            )
        )
    }
}
