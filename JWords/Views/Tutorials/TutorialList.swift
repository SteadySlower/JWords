//
//  TutorialList.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct ShowTutorial {}

struct TutorialList: View {
    
    let store: StoreOf<ShowTutorial>
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(Tutorial.allCases, id: \.self.title) { tutorial in
                    tutorialCell(tutorial)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
        }
        .navigationTitle("튜토리얼 보기")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .withBannerAD()
        #endif
    }
    
    private func tutorialCell(_ tutorial: Tutorial) -> some View {
        NavigationLink {
            TutorialPageView(tutorial)
        } label: {
            HStack {
                Text(tutorial.title)
                    .font(.title3)
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 20)
            .defaultRectangleBackground()
        }
    }
}

struct TutorialList_Previews: PreviewProvider {
    static var previews: some View {
        TutorialList(store: Store(initialState: .init(), reducer: { ShowTutorial() }))
    }
}
