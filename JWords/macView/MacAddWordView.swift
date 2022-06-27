//
//  MacAddWordView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

struct MacAddWordView: View {
    @State private var frontText: String = ""
    @State private var frontImage: NSImage?
    @State private var backText: String = ""
    @State private var backImage: NSImage?
    
    private var isSaveButtonUnable: Bool {
        return (frontText.isEmpty && frontImage == nil) || (backText.isEmpty && backImage == nil)
    }
    
    var body: some View {
        VStack {
            VStack {
                Text("앞면 입력")
                TextField("앞면 텍스트", text: $frontText)
                    .padding()
                if let frontImage = frontImage {
                    Image(nsImage: frontImage)
                        .resizable()
                        .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                        .onTapGesture { self.frontImage = nil }
                } else {
                    Button {
                        self.frontImage = getImageFromPasteBoard()
                    } label: {
                        Text("앞면 이미지")
                    }
                }
            }
            VStack {
                Text("뒷면 입력")
                TextField("뒷면 텍스트", text: $backText)
                    .padding()
                if let backImage = backImage {
                    Image(nsImage: backImage)
                        .resizable()
                        .frame(width: Constants.Size.deviceWidth * 0.8, height: 150)
                        .onTapGesture { self.backImage = nil }
                } else {
                    Button {
                        self.backImage = getImageFromPasteBoard()
                    } label: {
                        Text("뒷면 이미지")
                    }
                }
            }
            Button {
                // 뷰모델에서 저장
            } label: {
                Text("저장")
            }
            .disabled(isSaveButtonUnable)
        }
    }
    
    func getImageFromPasteBoard() -> NSImage? {
        let pb = NSPasteboard.general
        let type = NSPasteboard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
       
        return NSImage(data: imgData)
    }
}


struct MacAddWordView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddWordView()
    }
}
