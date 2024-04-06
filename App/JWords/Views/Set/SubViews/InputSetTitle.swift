//
//  InputSetTitle.swift
//  JWords
//
//  Created by JW Moon on 2023/10/04.
//

import SwiftUI
import CommonUI

struct InputSetTitle: View {
    
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: Constants.Size.SET_INPUT_FONT))
            .bold()
            .leadingAlignment()
    }
}

#Preview {
    InputSetTitle(title: "단어장 이름")
}
