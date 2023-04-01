//
//  Toggles.swift
//  JWords
//
//  Created by JW Moon on 2023/04/01.
//

import SwiftUI

struct AutoSearchToggle: View {
    
    @State private var autoSearch: Bool
    private let onTapped: (Bool) -> Void
    
    init(autoSearch: Bool, onTapped: @escaping (Bool) -> Void) {
        self.autoSearch = autoSearch
        self.onTapped = onTapped
    }
    
    var body: some View {
        Toggle("자동 검색", isOn: $autoSearch)
            .keyboardShortcut("f", modifiers: [.command])
            .onChange(of: autoSearch) { onTapped($0) }
    }
}


