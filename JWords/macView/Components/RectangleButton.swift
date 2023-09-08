//
//  RectangleButton.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/09/08.
//

import SwiftUI

struct RectangleButton: View {
    
    let image: Image
    let title: String
    let onTapped: () -> Void
    
    var body: some View {
        Button {
            onTapped()
        } label: {
            VStack {
                Spacer()
                image
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(title)
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
