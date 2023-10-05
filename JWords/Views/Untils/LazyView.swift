//
//  LazyView.swift
//  JWords
//
//  Created by JW Moon on 2023/01/21.
//

import SwiftUI

struct LazyView<Content: View>: View {
    private let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
