//
//  CoreDataClient.swift
//  JWords
//
//  Created by JW Moon on 2023/05/07.
//

import Foundation
import CoreData

class CoreDataClient {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "jwords")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
