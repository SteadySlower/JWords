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
                            onTapped: { store.send(.toStudySet($0)) }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear { store.send(.fetchSets) }
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

