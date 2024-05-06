//
//  InputFieldTitle.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import SwiftUI

public struct InputFieldTitle: View {
    
    let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some View {
        Text(LocalizedStringKey(title), bundle: .main)
            .font(.system(size: 20))
            .bold()
            .leadingAlignment()
    }
}

#Preview {
    InputFieldTitle(title: "한자")
}
