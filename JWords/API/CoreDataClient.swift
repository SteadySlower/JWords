//
//  CoreDataClient.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import Foundation
import CoreData

class CoreDataClient {
    
    static let shared = CoreDataClient()
    
    private lazy var context: NSManagedObjectContext = {
        let container = NSPersistentContainer(name: "jwords")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container.viewContext
    }()
    
    func insertSet(title: String, isAutoSchedule: Bool = true, preferredFrontType: FrontType = .kanji) throws {
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
        fetchRequest.predicate = NSPredicate(format: "closed == false")
        
        do {
            return try self.context.fetch(fetchRequest).map { StudySet(from: $0) }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func updateSet(_ set: StudySet,
                   title: String? = nil,
                   isAutoSchedule: Bool? = nil,
                   preferredFrontType: FrontType? = nil,
                   closed: Bool? = nil) throws {
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        if let title = title { set.title = title }
        if let isAutoSchedule = isAutoSchedule { set.isAutoSchedule = isAutoSchedule  }
        if let preferredFrontType = preferredFrontType { set.preferredFrontType = Int16(preferredFrontType.rawValue) }
        if let closed = closed { set.closed = closed }
        
        do {
            try context.save()
        } catch {
            context.rollback()
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
        
        return units.compactMap { $0 as? StudyUnitMO }.map { StudyUnit(from: $0) }
    }
    
    func insertUnit(in set: StudySet,
                    type: UnitType,
                    kanjiText: String,
                    kanjiImageID: String?,
                    meaningText: String,
                    meaningImageID: String?) throws {
        guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyUnit", into: context) as? StudyUnitMO else {
            print("디버그: StudyUnitMO 객체를 만들 수 없음")
            throw AppError.coreData
        }
        
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        HuriganaConverter.shared.extractKanjis(from: kanjiText )
            .compactMap { try? getKanjiMO($0) }
            .forEach { mo.addToKanjiOfWord($0) }
        
        mo.id = "unit_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        mo.type = Int16(type.rawValue)
        if !kanjiText.isEmpty { mo.kanjiText = kanjiText }
        mo.kanjiImageID = kanjiImageID
        if !meaningText.isEmpty { mo.meaningText = meaningText }
        mo.meaningImageID = meaningImageID
        mo.studyState = Int16(StudyState.undefined.rawValue)
        mo.createdAt = Date()
        mo.addToSet(set)
        
        do {
            try context.save()
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchAllKanjis() throws -> [StudyUnit] {
        let fetchRequest = StudyUnitMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == \(UnitType.kanji.rawValue)")
        
        do {
            return try context.fetch(fetchRequest).map { StudyUnit(from: $0) }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func fetchKanjis(usedIn unit: StudyUnit) throws -> [StudyUnit] {
        guard let mo = try? context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let kanjis = mo.kanjiOfWord else {
            return []
        }
        
        return kanjis.compactMap { $0 as? StudyUnitMO }.map { StudyUnit(from: $0) }
    }
    
    func fetchSampleUnit(ofKanji kanji: StudyUnit) throws -> [StudyUnit] {
        guard let mo = try? context.existingObject(with: kanji.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let samples = mo.sampleForKanji else {
            return []
        }
        
        return samples.compactMap { $0 as? StudyUnitMO }.map { StudyUnit(from: $0) }
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
    
    private func getKanjiMO(_ kanji: String) throws -> StudyUnitMO {
        let fetchRequest = StudyUnitMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "kanjiText == %@", kanji)
        
        do {
            if let fetched = try context.fetch(fetchRequest).first {
                return fetched
            } else {
                guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyUnit", into: context) as? StudyUnitMO else {
                    print("디버그: StudyUnitMO 객체를 만들 수 없음")
                    throw AppError.coreData
                }
                mo.id = "unit_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
                mo.type = Int16(UnitType.kanji.rawValue)
                mo.kanjiText = kanji
                mo.studyState = Int16(StudyState.undefined.rawValue)
                mo.createdAt = Date()
                return mo
            }
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
}