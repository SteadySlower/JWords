//
//  KVStorageClient.swift
//  JWords
//
//  Created by Jong Won Moon on 2023/08/09.
//

import Foundation

enum KVStorageKey: String {
    case studySets, reviewSets, reviewedSets, createdAt
}

final class KVStorageClient {
    
    static let shared = KVStorageClient()
    
    private let kv = NSUbiquitousKeyValueStore.default
    
    private func arrayOfString(for key: KVStorageKey) -> [String] {
        return kv.array(forKey: key.rawValue) as? [String] ?? []
    }
    
    private func date(for key: KVStorageKey) -> Date {
        return kv.object(forKey: key.rawValue) as? Date ?? Date()
    }
    
    private func setDate(key: KVStorageKey, value: Date) {
        kv.set(value, forKey: key.rawValue)
    }
    
    private func setArrayOfString(key: KVStorageKey, value: [String]) {
        kv.set(value, forKey: key.rawValue)
    }
    
    private func remove(key: KVStorageKey) {
        kv.removeObject(forKey: key.rawValue)
    }
}

// public Methods

extension KVStorageClient {
    
}
