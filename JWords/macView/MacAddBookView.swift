//
//  MacAddBookView.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import SwiftUI

// TODO: pasteboard에 있는 이미지를 가져오는 코드
struct MacAddBookView: View {
    @State private var frontText: String = ""
    @State private var frontImage: NSImage?
    @State private var backText: String = ""
    @State private var backImage: NSImage?
    
    var body: some View {
        VStack {
            VStack {
                Text("앞면 입력")
                TextField("앞면 텍스트", text: $frontText)
                if let frontImage = frontImage {
                    Image(nsImage: frontImage)
                        .resizable()
                        .frame(width: Constants.Size.deviceWidth * 0.9, height: 150)
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
                if let backImage = backImage {
                    Image(nsImage: backImage)
                        .resizable()
                        .frame(width: 100, height: 100)
                } else {
                    Button {
                        self.backImage = getImageFromPasteBoard()
                    } label: {
                        Text("뒷면 이미지")
                    }
                }
            }
        }
    }
    
    func getImageFromPasteBoard() -> NSImage? {
        let pb = NSPasteboard.general
        let type = NSPasteboard.PasteboardType.tiff
        guard let imgData = pb.data(forType: type) else { return nil }
       
        return NSImage(data: imgData)
    }
}

struct MacAddBookView_Previews: PreviewProvider {
    static var previews: some View {
        MacAddBookView()
    }
}
