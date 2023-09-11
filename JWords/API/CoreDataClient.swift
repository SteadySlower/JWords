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
    private let context: NSManagedObjectContext
    private let iu = CKImageUploader.shared
    
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
    
    func insertSet(title: String, isAutoSchedule: Bool, preferredFrontType: FrontType) throws {
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
                   preferredFrontType: FrontType,
                   closed: Bool) throws -> StudySet {
        guard let mo = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.title = title
        mo.isAutoSchedule = isAutoSchedule
        mo.preferredFrontType = Int16(preferredFrontType.rawValue)
        mo.closed = closed
        
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
                    kanjiImageID: String?,
                    meaningText: String,
                  meaningImageID: String?) throws -> StudyUnit {
        
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
    
    func addExistingUnit(unit: StudyUnit, meaningText: String, in set: StudySet) throws -> StudyUnit {
        guard let mo = try context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        if !meaningText.isEmpty { mo.meaningText = meaningText }
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
    
    
    func removeUnit(_ unit: StudyUnit, from set: StudySet) throws -> StudyUnit {
        guard let unitMO = try? context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let setMO = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        unitMO.removeFromSet(setMO)
        
        do {
            try context.save()
            return StudyUnit(from: unitMO)
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
        
    }
    
    func fetchAllKanjis() throws -> [Kanji] {
        let fetchRequest = StudyKanjiMO.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest).map { Kanji(from: $0) }
        } catch {
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
        
        return kanjis
            .compactMap { $0 as? StudyKanjiMO }
            .map { Kanji(from: $0) }
            .sorted(by: {
                kanjiList.firstIndex(of: $0.kanjiText) ?? 0 < kanjiList.firstIndex(of: $1.kanjiText) ?? 0
            })
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
    
    func editKanji(kanji: Kanji, meaningText: String) throws -> Kanji {
        guard let mo = try? context.existingObject(with: kanji.objectID) as? StudyKanjiMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.meaning = meaningText
        
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
    
    func moveUnits(_ units: [StudyUnit], from: StudySet, to: StudySet) throws {
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
                let wikiKanji = KanjiWikiClient.shared.getWikiKanji(kanji)
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

// MARK: Conversion
extension CoreDataClient {
    
    func checkIfExist(book: WordBook) throws -> Bool {
        let fetchRequest = StudySetMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", book.title)
        
        do {
            return try !context.fetch(fetchRequest).isEmpty
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func convertBook(book: WordBook) throws {
        guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudySet", into: context) as? StudySetMO else {
            print("디버그: StudySetMO 객체를 만들 수 없음")
            throw AppError.coreData
        }
        
        mo.id = "set_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        mo.title = book.title
        mo.preferredFrontType = Int16(book.preferredFrontType.rawValue)
        mo.isAutoSchedule = true
        mo.closed = false
        mo.createdAt = book.createdAt
        
        do {
            try context.save()
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func convert(input: ConversionInput, in set: StudySet) async throws -> StudyUnit {
        
        guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyUnit", into: context) as? StudyUnitMO else {
            print("디버그: StudyUnitMO 객체를 만들 수 없음")
            throw AppError.coreData
        }
        
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        if let kanjiImage = input.kanjiImage {
            mo.kanjiImageID = try await iu.saveImage(data: kanjiImage)
        }
        
        if let meaningImage = input.meaningImage {
            mo.meaningImageID = try await iu.saveImage(data: meaningImage)
        }
        
        HuriganaConverter.shared.extractKanjis(from: input.kanjiText)
            .compactMap { try? getKanjiMO($0) }
            .forEach { mo.addToKanjis($0) }
        
        mo.id = "unit_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        mo.type = Int16(input.type.rawValue)
        if !input.kanjiText.isEmpty { mo.kanjiText = input.kanjiText }
        if !input.meaningText.isEmpty { mo.meaningText = input.meaningText }
        mo.studyState = Int16(input.studyState.rawValue)
        mo.createdAt = input.createdAt
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
    
    func convert(inputs: [ConversionInput], in set: StudySet) async throws -> [StudyUnit] {
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        var addedMO = [StudyUnitMO]()
        
        for input in inputs {
            guard let mo = NSEntityDescription.insertNewObject(forEntityName: "StudyUnit", into: context) as? StudyUnitMO else {
                print("디버그: StudyUnitMO 객체를 만들 수 없음")
                throw AppError.coreData
            }
            
            if let kanjiImage = input.kanjiImage {
                mo.kanjiImageID = try await iu.saveImage(data: kanjiImage)
            }
            
            if let meaningImage = input.meaningImage {
                mo.meaningImageID = try await iu.saveImage(data: meaningImage)
            }
            
            HuriganaConverter.shared.extractKanjis(from: input.kanjiText)
                .compactMap { try? getKanjiMO($0) }
                .forEach { mo.addToKanjis($0) }
            
            mo.id = "unit_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
            mo.type = Int16(input.type.rawValue)
            if !input.kanjiText.isEmpty { mo.kanjiText = input.kanjiText }
            if !input.meaningText.isEmpty { mo.meaningText = input.meaningText }
            mo.studyState = Int16(input.studyState.rawValue)
            mo.createdAt = input.createdAt
            mo.addToSet(set)
            
            addedMO.append(mo)
        }
        
        do {
            try context.save()
            return addedMO.map { StudyUnit(from: $0) }
        } catch let error as NSError {
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
    
    func convert(unit: StudyUnit, newMeaning: String, in set: StudySet) throws -> StudyUnit {
        
        guard let mo = try? context.existingObject(with: unit.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        guard let set = try? context.existingObject(with: set.objectID) as? StudySetMO else {
            print("디버그: objectID로 set 찾을 수 없음")
            throw AppError.coreData
        }
        
        mo.meaningText = newMeaning
        mo.addToSet(set)
        
        do {
            try context.save()
            return StudyUnit(from: mo)
        } catch {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
        
    }
    
    func resetCoreData() throws {
//        let setFetchRequest: NSFetchRequest<StudySetMO> = StudySetMO.fetchRequest()
//        let unitFetchRequest: NSFetchRequest<StudyUnitMO> = StudyUnitMO.fetchRequest()
//
//        do {
//            let sets = try context.fetch(setFetchRequest)
//            for set in sets {
//                context.delete(set)
//            }
//
//            let units = try context.fetch(unitFetchRequest)
//            for unit in units {
//                context.delete(unit)
//            }
//
//            try context.save()
//
//        } catch {
//            context.rollback()
//            NSLog("CoreData Error: %s", error.localizedDescription)
//            throw AppError.coreData
//        }
//
    }
}

// MARK: Interim function to convert kanjis from StudyUnit to StudyKanji

extension CoreDataClient {
    
    private func checkIfExist(kanji: String) throws -> Bool {
        
        let fetchRequest = StudyKanjiMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "kanji == %@", kanji)
        
        do {
            return (try context.fetch(fetchRequest).first != nil)
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    private func convertKanjisToStudyKanji(kanji: StudyUnitMO) throws {
        guard let kanjiText = kanji.kanjiText else {
            print("디버그: kanjiText 없음")
            return
        }
        
        // 중복 검사
        guard !(try! checkIfExist(kanji: kanjiText)) else {
            print("디버그: 이미 DB에 존재하는 한자")
            return
        }
        
        // StudyUnitMO 찾기
        guard let unitMO = try? context.existingObject(with: kanji.objectID) as? StudyUnitMO else {
            print("디버그: objectID로 unit 찾을 수 없음")
            throw AppError.coreData
        }
        
        // mo에 넣기
        guard let studyKanjimo = NSEntityDescription.insertNewObject(forEntityName: "StudyKanji", into: context) as? StudyKanjiMO else {
            throw AppError.coreData
        }
        
        let wikiKanji = KanjiWikiClient.shared.getWikiKanji(kanjiText)
        
        studyKanjimo.id = "kanji_" + UUID().uuidString + "_" + String(Int(Date().timeIntervalSince1970))
        studyKanjimo.kanji = kanji.kanjiText
        studyKanjimo.meaning = kanji.meaningText
        studyKanjimo.ondoku = wikiKanji?.ondoku ?? ""
        studyKanjimo.kundoku = wikiKanji?.kundoku ?? ""
        studyKanjimo.createdAt = kanji.createdAt
        
        // mo에 unit과 연결
        let words = unitMO.sampleForKanji ?? []
        studyKanjimo.addToWords(words)
        
        do {
            try context.save()
            print("디버그) 이동한 kanji: \(studyKanjimo.kanji!)")
        } catch let error as NSError {
            context.rollback()
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    private func fetchOldKanjis() throws -> [StudyUnitMO] {
        let fetchRequest = StudyUnitMO.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "type == \(UnitType.kanji.rawValue)")
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            NSLog("CoreData Error: %s", error.localizedDescription)
            throw AppError.coreData
        }
    }
    
    func convertAllKanjisToStudyKanji() throws {
        let oldKanjis = try! fetchOldKanjis()
        
        for kanji in oldKanjis {
            try! convertKanjisToStudyKanji(kanji: kanji)
        }
    }
    
}
