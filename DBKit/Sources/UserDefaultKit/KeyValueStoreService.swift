//
//  KeyValueStoreService.swift
//  JWords
//
//  Created by JW Moon on 2023/10/03.
//

import Foundation

public enum KVStorageKey: String {
    case studySets, reviewSets, createdAt
}

public final class KeyValueStoreService {
    
    public static let shared = KeyValueStoreService()
    
    private let kv = NSUbiquitousKeyValueStore.default
    
    public func arrayOfString(for key: KVStorageKey) -> [String] {
        return kv.array(forKey: key.rawValue) as? [String] ?? []
    }
    
    public func date(for key: KVStorageKey) -> Date {
        return kv.object(forKey: key.rawValue) as? Date ?? Date()
    }
    
    public func setDate(key: KVStorageKey, value: Date) {
        kv.set(value, forKey: key.rawValue)
        kv.synchronize()
    }
    
    public func setArrayOfString(key: KVStorageKey, value: [String]) {
        kv.set(value, forKey: key.rawValue)
        kv.synchronize()
    }
    
    public func remove(key: KVStorageKey) {
        kv.removeObject(forKey: key.rawValue)
        kv.synchronize()
    }
}

