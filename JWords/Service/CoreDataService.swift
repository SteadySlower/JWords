//
//  CoreDataService.swift
//  JWords
//
//  Created by JW Moon on 2023/10/02.
//

import Foundation
import CoreData

class CoreDataService {
    
    static let shared = CoreDataService()
    private let context: NSManagedObjectContext
    private let kw = KanjiWikiService.shared
    
    init() {
        let container = NSPersistentCloudKitContainer(name: "jwords")
        container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        self.context = container.viewContext
    }
    
    func insertSet(title: String, isAutoSchedule: Bool, preferredFrontType: FrontType) throws -> StudySet {
        guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudySet", into: context) as? StudySetMO else {
            print("디버그: StudySetMO 객체를 만들 수 없음")
            throw AppError.coreData
        }
        
        mo.id = "set_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        mo.title = title
        mo.preferredFrontType = Int16(preferredFrontType.rawValue)
        mo.isAutoSchedule = isAutoSchedule
        mo.closed = false
        mo.createdAt = Date()
        
        do {
            try context.save()
            return StudySet(from: mo)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchSets(includeClosed: Bool = false) throws -> [StudySet] {
        let fetchRequest: NSFetchRequest<StudySetMO> = StudySetMO.fetchRequest()
        let createdAtDesc = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAtDesc]
        if !includeClosed {
            fetchRequest.predicate = NSPredicate(format: "closed == false")
        }
        
        do {
            return try self.context.fetch(fetchRequest).map { StudySet(from: $0) }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func updateSet(_ set: StudySet,
                   title: String,
                   isAutoSchedule: Bool,
                   preferredFrontType: FrontType) throws -> StudySet {
        guard let mo = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.title = title
        mo.isAutoSchedule = isAutoSchedule
        mo.preferredFrontType = Int16(preferredFrontType.rawValue)
        
        do {
            try context.save()
            return StudySet(from: mo)
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func countUnits(in set: StudySet) throws -> Int {
        guard let mo = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let result = mo.units?.count else {
            print("디버그: setMO의 units가 nil")
            throw AppError.coreData
        }
        
        return result
    }
    
    func closeSet(_ set: StudySet) throws {
        guard let mo = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.closed = true
        
        do {
            try context.save()
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func checkIfExist(_ kanjiText: String) throws -> StudyUnit? {
        
        if kanjiText.isEmpty { return nil }
        
        let fetchRequest = StudyUnitMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "kanjiText == %@", kanjiText)
        
        do {
            if let fetched = try context.fetch(fetchRequest).first {
                return StudyUnit(from: fetched)
            } else {
                return nil
            }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchUnits(of set: StudySet) throws -> [StudyUnit] {
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let units = set.units else {
            print("디버그: units가 nil")
            throw AppError.coreData
        }
        
        return units.compactMap { $0 as? StudyUnitMO }.map { StudyUnit(from: $0) }.sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    func insertUnit(in set: StudySet,
                    type: UnitType,
                    kanjiText: String,
                    meaningText: String) throws -> StudyUnit {
        guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyUnit", into: context) as? StudyUnitMO else {
            print("디버그: StudyUnitMO 객체를 만들 수 없음")
            throw AppError.coreData
        }
        
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        HuriganaConverter.shared.extractKanjis(from: kanjiText)
            .compactMap { try? getKanjiMO($0) }
            .forEach { mo.addToKanjis($0) }
        
        mo.id = "unit_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        mo.type = Int16(type.rawValue)
        mo.kanjiText = kanjiText
        mo.meaningText = meaningText
        mo.studyState = Int16(StudyState.undefined.rawValue)
        mo.createdAt = Date()
        mo.addToSet(set)
        
        do {
            try context.save()
            return StudyUnit(from: mo)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func editUnit(of unit: StudyUnit,
                    type: UnitType,
                    kanjiText: String,
                    kanjiImageID: String? = nil,
                    meaningText: String,
                  meaningImageID: String? = nil) throws -> StudyUnit {
        
        guard let mo = try context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        let previousKanjis = mo.kanjis ?? []
        let nowKanjis = HuriganaConverter.shared.extractKanjis(from: kanjiText)
                            .compactMap { try? getKanjiMO($0) }
        let toRemoveKanjis = Set(_immutableCocoaSet: previousKanjis)
                            .subtracting(Set(nowKanjis))
        
        toRemoveKanjis
            .forEach { mo.removeFromKanjis($0) }
        
        nowKanjis
            .forEach { mo.addToKanjis($0) }
        
        mo.type = Int16(type.rawValue)
        mo.kanjiText = kanjiText
        mo.kanjiImageID = kanjiImageID
        mo.meaningText = meaningText
        mo.meaningImageID = meaningImageID

        do {
            try context.save()
            return StudyUnit(from: mo)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func addExistingUnit(set: StudySet, unit: StudyUnit) throws -> StudyUnit {
        guard let mo = try context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }

        mo.addToSet(set)
        
        do {
            try context.save()
            return StudyUnit(from: mo)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    // API for pagination
    func fetchAllKanjis(after: Kanji?) throws -> [Kanji] {
        let fetchRequest = StudyKanjiMO.fetchRequest()
        var predicates = [NSPredicate]()
        if let after = after {
            predicates.append(NSPredicate(format: "createdAt < %@", after.createdAt as NSDate))
        }
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = KanjiList.NUMBER_OF_KANJI_IN_A_PAGE
        
        do {
            return try context.fetch(fetchRequest).map { Kanji(from: $0) }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchKanjis(usedIn unit: StudyUnit) throws -> [Kanji] {
        guard let mo = try? context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let kanjis = mo.kanjis else {
            return []
        }
        
        let kanjiList = unit.kanjiText.filter { $0.isKanji }.map { String($0) }
        
        let sorted = kanjis
            .compactMap { $0 as? StudyKanjiMO }
            .map { Kanji(from: $0) }
            .sorted(by: {
                kanjiList.firstIndex(of: $0.kanjiText) ?? 0 < kanjiList.firstIndex(of: $1.kanjiText) ?? 0
            })
        
        var result = [Kanji]()
        
        for kanji in sorted {
            if result.filter({ $0.kanjiText == kanji.kanjiText }).isEmpty {
                result.append(kanji)
            }
        }
        
        return result
    }
    
    func fetchKanjis(query: String) throws -> [Kanji] {
        let fetchRequest: NSFetchRequest<StudyKanjiMO> = StudyKanjiMO.fetchRequest()
        
        let kanjiPredicate = NSPredicate(format: "kanji CONTAINS[cd] %@", query)
        let meaningPredicate = NSPredicate(format: "meaning CONTAINS[cd] %@", query)
        let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [kanjiPredicate, meaningPredicate])
        
        fetchRequest.predicate = combinedPredicate
        
        do {
            return try self.context.fetch(fetchRequest).map { Kanji(from: $0) }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchSampleUnit(ofKanji kanji: Kanji) throws -> [StudyUnit] {
        guard let mo = try? context.existingObject(with: kanji.objectID) as? StudyKanjiMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let samples = mo.words else {
            return []
        }
        
        return samples.compactMap { $0 as? StudyUnitMO }.map { StudyUnit(from: $0) }
    }
    
    func editKanji(kanji: Kanji, input: StudyKanjiInput) throws -> Kanji {
        guard let mo = try? context.existingObject(with: kanji.objectID) as? StudyKanjiMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.meaning = input.meaningText
        mo.ondoku = input.ondoku
        mo.kundoku = input.kundoku
        
        do {
            try context.save()
            return Kanji(from: mo)
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
        
    }
    
    func updateStudyState(unit: StudyUnit, newState: StudyState) throws {
        guard let mo = try? context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.studyState = Int16(newState.rawValue)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func moveUnits(units: [StudyUnit], from: StudySet, to: StudySet) throws {
        guard let fromSetMO = try? context.existingObject(with: from.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let toSetMO = try? context.existingObject(with: to.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        units.compactMap { unit in
            try? context.existingObject(with: unit.objectID) as? StudyUnitMO
        }.forEach { mo in
            mo.removeFromSet(fromSetMO)
            mo.addToSet(toSetMO)
        }
        
        do {
            try context.save()
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
        
    }
    
    func deleteUnit(unit: StudyUnit, from set: StudySet) throws {
        guard let unitMO = try? context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let setMO = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        unitMO.removeFromSet(setMO)
        setMO.removeFromUnits(unitMO)
        
        do {
            try context.save()
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    private func getKanjiMO(_ kanji: String) throws -> StudyKanjiMO {
        let fetchRequest = StudyKanjiMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "kanji == %@", kanji)
        
        do {
            if let fetched = try context.fetch(fetchRequest).first {
                return fetched
            } else {
                guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyKanji", into: context) as? StudyKanjiMO else {
                    print("디버그: StudyKanjiMO 객체를 만들 수 없음")
                    throw AppError.coreData
                }
                let wikiKanji = kw.getWikiKanji(kanji)
                mo.id = "kanji_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
                mo.kanji = kanji
                mo.meaning = wikiKanji?.meaning ?? ""
                mo.ondoku = wikiKanji?.ondoku ?? ""
                mo.kundoku = wikiKanji?.kundoku ?? ""
                mo.createdAt = Date()
                return mo
            }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
}

// MARK: API for Writing Kanjis

extension CoreDataService {
    
    func insertKanjiSet(title: String, isAutoSchedule: Bool) throws -> KanjiSet {
        guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyKanjiSet", into: context) as? StudyKanjiSetMO else {
            print("디버그: StudyKanjiSetMO 객체를 만들 수 없음")
            throw AppError.coreData
        }
        
        mo.id = "kanjiSet_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        mo.title = title
        mo.isAutoSchedule = isAutoSchedule
        mo.closed = false
        mo.createdAt = Date()
        
        do {
            try context.save()
            return KanjiSet(from: mo)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchKanjiSets(includeClosed: Bool = false) throws -> [KanjiSet] {
        let fetchRequest: NSFetchRequest<StudyKanjiSetMO> = StudyKanjiSetMO.fetchRequest()
        let createdAtDesc = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAtDesc]
        if !includeClosed {
            fetchRequest.predicate = NSPredicate(format: "closed == false")
        }
        
        do {
            return try self.context.fetch(fetchRequest).map { KanjiSet(from: $0) }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func updateStudyState(kanji: Kanji, newState: StudyState) throws {
        guard let mo = try? context.existingObject(with: kanji.objectID) as? StudyKanjiMO else {
            print("디버그: objectID로 kanji 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.studyState = Int16(newState.rawValue)
        
        do {
            try context.save()
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchKanjis(kanjiSet: KanjiSet) throws -> [Kanji] {
        guard let set = try? context.existingObject(with: kanjiSet.objectID) as? StudyKanjiSetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let kanjis = set.kanjis else {
            print("디버그: units가 nil")
            throw AppError.coreData
        }
        
        return kanjis
            .compactMap { $0 as? StudyKanjiMO }
            .map { Kanji(from: $0) }
            .sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    func insertKanji(_ kanji: Kanji, in set: KanjiSet) throws -> KanjiSet {
        guard let kanjiMO = try? context.existingObject(with: kanji.objectID) as? StudyKanjiMO else {
            print("디버그: objectID로 kanji 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let setMO = try? context.existingObject(with: set.objectID) as? StudyKanjiSetMO else {
            print("디버그: objectID로 study kanji set 찾을 수 없음")
            throw AppError.coreData
        }
        
        kanjiMO.addToSet(setMO)
        
        do {
            try context.save()
            return KanjiSet(from: setMO)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
}
