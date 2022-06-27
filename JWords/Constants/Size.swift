//
//  Size.swift
//  JWords
//
//  Created by Jong Won Moon on 2022/06/27.
//

import CoreGraphics
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// TODO: multiplatform 에서 화면 크기 얻는 방법 정리하기
enum Constants {
    enum Size {        
        static var deviceWidth: CGFloat {
            #if os(iOS)
            UIScreen.main.bounds.width
            #elseif os(macOS)
            NSScreen.main?.visibleFrame.width ?? 300.0
            #endif
        }
    }
}
