//
//  SelectionCell.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/04/20.
//

import SwiftUI
import Combine
import ComposableArchitecture

struct SelectUnit: Reducer {
    struct State: Equatable, Identifiable {
        let id: String
        let unit: StudyUnit
        let frontType: FrontType
        var isSelected: Bool
        
        init(unit: StudyUnit, frontType: FrontType = .kanji) {
            self.id = unit.id
            self.unit = unit
            self.frontType = frontType
            self.isSelected = false
        }
        
    }
    
    enum Action: Equatable {
        case cellTapped
    }
    
    
    var body: some Reducer<State, Action> {
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
    
    let store: StoreOf<SelectUnit>
    @State private var dashPhase: CGFloat = 0
    private let selectedColor: Color = Color.blue.opacity(0.2)
    private let unselectedColor: Color = Color.gray.opacity(0.2)
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { vs in
            BaseCell(unit: vs.unit,
                     frontType: vs.frontType)
                .overlay { vs.isSelected ? AnyView(selectedOverlay) : AnyView(unselectedOverlay) }
                .onTapGesture { vs.send(.cellTapped) }
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
                initialState: SelectUnit.State(unit: StudyUnit(index: 0)),
                reducer: { SelectUnit()._printChanges() }
            )
        )
    }
}
