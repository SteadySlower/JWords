//
//  HomeView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI
import ComposableArchitecture
import Model
import CommonUI
import Cells
import AdView

struct HomeView: View {
    
    @Bindable var store: StoreOf<HomeList>
    
    var body: some View {
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
                        SetCell(
                            title: set.title,
                            dayFromToday: set.dayFromToday,
                            dateTextColor: set.schedule.labelColor,
                            onTapped: {  }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .withBannerAD()
        .navigationTitle("모든 단어장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .loadingView(store.isLoading)
        .onAppear { store.send(.fetchSets) }
//        .sheet(item: $store.scope(state: \.destination?.addSet, action: \.destination.addSet)) {
//            AddSetView(store: $0)
//        }
        .toolbar {
            ToolbarItem {
                Button {
                    store.send(.toAddSet)
                } label: {
                    Image(systemName: "folder.badge.plus")
                        .resizable()
                        .foregroundColor(.black)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView(
                store: Store(
                    initialState: HomeList.State(),
                    reducer: { HomeList()._printChanges() }
                )
            )
        }
    }
}
