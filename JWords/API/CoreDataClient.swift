//
//  CoreDataClient.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import Foundation
import CoreData

class CoreDataClient {
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
        var result = [StudySet]()
        
        let fetchRequest: NSFetchRequest<StudySetMO> = StudySetMO.fetchRequest()
        let createdAtDesc = NSSortDescriptor(key: "createdAt", ascending: false)
        fetchRequest.sortDescriptors = [createdAtDesc]
        fetchRequest.predicate = NSPredicate(format: "closed == true")
        
        do {
            let MOs = try self.context.fetch(fetchRequest)
            for mo in MOs {
                let set = StudySet(from: mo)
                result.append(set)
            }
        } catch let error as NSError {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
        
        return result
    }
}
