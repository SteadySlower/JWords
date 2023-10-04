//
//  KeyValueStoreService.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Foundation

enum KVStorageKey: String {
    case studySets, reviewSets, reviewedSets, createdAt
}

final class KeyValueStoreService {
    
    static let shared = KeyValueStoreService()
    
    private let kv = NSUbiquitousKeyValueStore.default
    
    func arrayOfString(for key: KVStorageKey) -> [String] {
        return kv.array(forKey: key.rawValue) as? [String] ?? []
    }
    
    func date(for key: KVStorageKey) -> Date {
        return kv.object(forKey: key.rawValue) as? Date ?? Date()
    }
    
    func setDate(key: KVStorageKey, value: Date) {
        kv.set(value, forKey: key.rawValue)
        kv.synchronize()
    }
    
    func setArrayOfString(key: KVStorageKey, value: [String]) {
        kv.set(value, forKey: key.rawValue)
        kv.synchronize()
    }
    
    func remove(key: KVStorageKey) {
        kv.removeObject(forKey: key.rawValue)
        kv.synchronize()
    }
}

