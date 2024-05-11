//
//  RemoveImageButton.swift
//  JWords
//
//  Created by JW Moon on 5/11/24.
//

import SwiftUI

struct RemoveImageButton: View {
    
    let onTapped: () -> Void
    
    var body: some View {
        RectangleButton(
            image: Image(systemName: "photo.on.rectangle.angled"),
            title: "다른 이미지 스캔하기",
            isVertical: false,
            onTapped: onTapped
        )
        .padding(.horizontal, 20)
    }
    
}
