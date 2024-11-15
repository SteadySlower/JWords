//
//  File.swift
//  
//
//  Created by JW Moon on 5/6/24.
//

import SwiftUI
import ComposableArchitecture
import Model
import CommonUI

public struct StudySetListView: View {
    
    @Bindable var store: StoreOf<StudySetList>
    
    public init(store: StoreOf<StudySetList>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            if store.isDeleteMode {
                Text("삭제할 단어장을 골라주세요.\n삭제된 단어장은 복구할 수 없습니다.")
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            Picker("닫힌 단어장", selection: $store.includeClosed.sending(\.setIncludeClosed)) {
                Text("열린 단어장").tag(false)
                Text("모든 단어장").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 100)
            .padding(.top, 20)
            ScrollView {
                VStack(spacing: 8) {
                    VStack {}.frame(height: 20)
                    ForEach(store.sets, id: \.id) { set in
                        StudySetCell(
                            set: set,
                            onTapped: { set in
                                if !store.isDeleteMode {
                                    store.send(.toStudySet(set))
                                } else {
                                    store.send(.toDeleteSet(set))
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear { store.send(.fetchSets) }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        StudySetListView(
            store: Store(
                initialState: StudySetList.State(),
                reducer: { StudySetList()._printChanges() }
            )
        )
    }
}

