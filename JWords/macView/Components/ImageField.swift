//
//  ImageField.swift
//  JWords
//
//  Created by JW Moon on 2023/03/19.
//

import SwiftUI

struct ImageField: View {
    
    private let inputType: InputType
    private let image: InputImageType?
    private let addImageButtonTapped: (InputType) -> Void
    private let imageTapped: (InputType) -> Void
    
    init(inputType: InputType,
         image: InputImageType?,
         addImageButtonTapped: @escaping (InputType) -> Void,
         imageTapped: @escaping (InputType) -> Void)
    {
        self.inputType = inputType
        self.image = image
        self.addImageButtonTapped = addImageButtonTapped
        self.imageTapped = imageTapped
    }
    
    var body: some View {
        Group {
            if image != nil {
                imageView
                    .onTapGesture { imageTapped(inputType) }
            } else {
                addButton
            }
        }
    }
}

// MARK: SubViews

extension ImageField {
    
    private var imageView: some View {
        #if os(iOS)
        Image(uiImage: image)
            .resizable()
            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
        #elseif os(macOS)
        // TODO: remove force unwrapping
        Image(nsImage: image!)
            .resizable()
            .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
        #endif
    }
    
    private var addButton: some View {
        Button {
            addImageButtonTapped(inputType)
        } label: {
            Text("\(inputType.description) 이미지")
        }
    }
    
}
