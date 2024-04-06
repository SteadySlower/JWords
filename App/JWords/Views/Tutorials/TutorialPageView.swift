//
//  TutorialPageView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI
import Model

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
            #if os(iOS)
            .tabViewStyle(.page)
            #endif
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .navigationTitle(tutorial.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    private func setIndicator() {
        #if os(iOS)
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.blue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.blue.opacity(0.5))
        #endif
    }

}

struct TutorialPageView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialPageView(.addSet)
    }
}
