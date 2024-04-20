//
//  File.swift
//  
//
//  Created by JW Moon on 4/20/24.
//

import CoreGraphics
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// TODO: multiplatform 에서 화면 크기 얻는 방법 정리하기
// TODO: 윈도우 크기 바뀌면 이 값도 따라서 바뀌어야 함

let DEVICE_WIDTH: CGFloat = {
    #if os(iOS)
    UIScreen.main.bounds.width
    #elseif os(macOS)
    NSApplication.shared.windows.first?.frame.width ?? 300
    #endif
}()

let DEVICE_HEIGHT: CGFloat = {
    #if os(iOS)
    UIScreen.main.bounds.height
    #elseif os(macOS)
    NSApplication.shared.windows.first?.frame.height ?? 300
    #endif
}()
