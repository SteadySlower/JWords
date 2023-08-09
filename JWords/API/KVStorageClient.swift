//
//  KVStorageClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/08/09.
//

import Foundation

final class KVStorageClient {
    
    static let shared = KVStorageClient()
    
    private let kv = NSUbiquitousKeyValueStore()
    
}
