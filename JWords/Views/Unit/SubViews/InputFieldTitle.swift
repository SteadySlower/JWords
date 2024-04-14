//
//  InputFieldTitle.swift
//  JWords
//
//  Created by JW Moon on 2023/09/26.
//

import SwiftUI
import CommonUI

struct InputFieldTitle: View {
    
    let title: String
    
    var body: some View {
        Text(title.localize())
            .font(.system(size: Constants.Size.UNIT_INPUT_FONT - 10))
            .bold()
            .leadingAlignment()
    }
}

#Preview {
    InputFieldTitle(title: "한자")
}
