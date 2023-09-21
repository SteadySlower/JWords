//
//  TutorialPageView.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/21.
//

import SwiftUI

struct TutorialPageView: View {
    
    @State var index: Int = 1
    
    init() {
        setIndicator()
    }
    
    var body: some View {
        VStack {
            TabView(selection: $index) {
                ForEach(1..<5) { i in
                    Image("Add Book \(i)")
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
        .padding(.bottom, 20)
    }
    
    private func setIndicator() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.blue)
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.blue.opacity(0.5))
    }

}

struct TutorialPageView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialPageView()
    }
}
