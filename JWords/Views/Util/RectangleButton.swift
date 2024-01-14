//
//  RectangleButton.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/08.
//

import SwiftUI

struct RectangleButton: View {
    
    let image: Image?
    let title: String
    let onTapped: () -> Void
    let isVertical: Bool
    
    init(image: Image? = nil, title: String,  isVertical: Bool = true, onTapped: @escaping () -> Void) {
        self.image = image
        self.title = title
        self.onTapped = onTapped
        self.isVertical = isVertical
    }
    
    var body: some View {
        Button {
            onTapped()
        } label: {
            if isVertical {
                VStack {
                    Spacer()
                    if let image = image {
                        image
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(title.localize())
                        .fixedSize()
                    Spacer()
                }
                .padding(8)
                .foregroundColor(.black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                )
            } else {
                HStack {
                    Spacer()
                    if let image = image {
                        image
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                    Text(title.localize())
                    Spacer()
                }
                .padding(8)
                .foregroundColor(.black)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                        .shadow(color: Color.gray.opacity(0.5), radius: 4, x: 0, y: 2)
                )
            }

        }
    }
    
}
