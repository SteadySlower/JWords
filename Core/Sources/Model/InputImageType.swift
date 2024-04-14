//
//  InputImageType.swift
//  JWords
//
//  Created by JW Moon on 2023/10/02.
//

#if os(iOS)
import UIKit
public typealias InputImageType = UIImage
#elseif os(macOS)
import Cocoa
public typealias InputImageType = NSImage
#endif
