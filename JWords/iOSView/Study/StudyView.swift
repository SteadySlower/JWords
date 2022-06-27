//
//  StudyView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct StudyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(0..<20) { _ in
                        WordCell()
                    }
                }
            }
        }
        .navigationTitle("2과 단어장")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct StudyView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
