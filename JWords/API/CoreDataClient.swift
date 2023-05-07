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
        let mo = NSEntityDescription.insertNewObject(forEntityName: "StudySet", into: context) as! StudySetMO
        
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
}
