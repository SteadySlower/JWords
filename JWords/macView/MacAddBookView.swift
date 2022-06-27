//
//  MacAddBookView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

// TODO: pasteboard에 있는 이미지를 가져오는 코드
struct MacAddBookView: View {
    @State private var bookName: String = ""
    
    var body: some View {
        TextField("단어장 이름", text: $bookName)
    }
}

struct MacAddBookView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddBookView()
    }
}
