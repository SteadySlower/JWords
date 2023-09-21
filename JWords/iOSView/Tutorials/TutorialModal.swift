//
//  TutorialModal.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI

struct TutorialModal: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("튜토리얼 보기")
                    .font(.title)
                    .leadingAlignment()
                    .padding(.bottom, 10)
                ForEach(Tutorial.allCases, id: \.self.title) { tutorial in
                    tutorialCell(tutorial)
                }
            }
            .padding(.horizontal, 10)
        }
    }
    
    private func tutorialCell(_ tutorial: Tutorial) -> some View {
        Button {
            print("디버그: \(tutorial.title) Tapped")
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

struct TutorialModal_Previews: PreviewProvider {
    static var previews: some View {
        TutorialModal()
    }
}
