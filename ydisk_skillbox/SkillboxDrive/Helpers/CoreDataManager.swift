//
//  CoreDataManager.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 29.11.2022.
//

import Foundation
import CoreData

class CoreDataManager {
    
    enum elementType{
        case wrongType
        case document
        case image
        case pdf
    }
    
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var context: NSManagedObjectContext = {
        persistentContainer.viewContext
    }()
    
    lazy var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        let sortDescriptor = NSSortDescriptor(key: "modified", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultController
    }()
    
    func count() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch { print(error.localizedDescription) }
        return -1
    }
    
    func isUnique(diskItem: DiskItem) -> Bool {
        var isUnique = true
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(fetchRequest) as! [YDiskItem]
            if allData.first(where: { $0.name == diskItem.name }) != nil {
//                print("is not unique: \(diskItem.name!): \(diskItem.md5)")
                isUnique = false
            }
        } catch {
            print("error while isUnique is checked: \(error.localizedDescription)")
        }
        
        return isUnique
    }
    
    func deleteIfNotPresented(diskItemArray: [DiskItem]) {
        let idsArray = diskItemArray.map { $0.name }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(fetchRequest) as! [YDiskItem]
            allData.forEach { yDiskItem in
                if !idsArray.contains(yDiskItem.name) {
//                    print("deleting: \(yDiskItem.name)")
                    context.delete(yDiskItem)
                }
            }
        } catch {
            print("error performing deletion and inserting: \(error.localizedDescription)")
        }
    }
    
    func printData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(fetchRequest)
            for object in allData as! [YDiskItem] {
                print(object.md5!)
            }
        } catch {
            print("error while printing IDs: \(error.localizedDescription)")
        }
    }
    
    func deleteAllEntities() {
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(deleteRequest)
            for object in allData as! [NSManagedObject] {
                context.delete(object)
            }
        } catch {
            print("error while delete all CoreData: \(error.localizedDescription)")
        }
        self.saveContext()
    }
    
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: context)!
    }
    
    
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
