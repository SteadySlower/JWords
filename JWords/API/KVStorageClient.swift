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
    func fetchSchedule() -> TodaySchedule {
        TodaySchedule(studyIDs: arrayOfString(for: .studySets),
                      reviewIDs: arrayOfString(for: .reviewSets),
                      reviewedIDs: arrayOfString(for: .reviewedSets),
                      createdAt: date(for: .createdAt))
    }
    
    func autoSetSchedule(sets: [StudySet]) {
        let studySets = sets.filter { $0.schedule == .study }.map { $0.id }
        let reviewSets = sets.filter { $0.schedule == .review }.map { $0.id }
        setArrayOfString(key: .studySets, value: studySets)
        setArrayOfString(key: .reviewSets, value: reviewSets)
        setArrayOfString(key: .reviewedSets, value: [])
        setDate(key: .createdAt, value: Date())
    }
    
    func updateSchedule(todaySchedule: TodaySchedule) {
        setArrayOfString(key: .studySets, value: todaySchedule.studyIDs)
        setArrayOfString(key: .reviewSets, value: todaySchedule.reviewIDs)
        setArrayOfString(key: .reviewedSets, value: todaySchedule.reviewedIDs)
        setDate(key: .createdAt, value: Date())
    }
    
    func addReviewedSet(reviewed: StudySet) {
        var reviewedIDs = arrayOfString(for: .reviewedSets)
        reviewedIDs.append(reviewed.id)
        setArrayOfString(key: .reviewedSets, value: reviewedIDs)
        setDate(key: .createdAt, value: Date())
    }
}
