//
//  TutorialPageView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI

struct TutorialPageView: View {
    
    @State var index: Int = 0
    private let tutorial: Tutorial
    
    init(_ tutorial: Tutorial) {
        self.tutorial = tutorial
        setIndicator()
    }
    
    var body: some View {
        VStack {
            TabView(selection: $index) {
                ForEach(0..<tutorial.imageCount, id: \.self) { i in
                    Image("\(tutorial.imageName) \(i + 1)")
                        .resizable()
                        .padding(.vertical, 30)
                        .scaledToFit()
                        .tag(i)
                        .defaultRectangleBackground()
                }
            }
            .tabViewStyle(.page)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .navigationTitle(tutorial.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func setIndicator() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.blue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.blue.opacity(0.5))
    }

}

struct TutorialPageView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialPageView(.addWord)
    }
}
