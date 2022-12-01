//
//  CoreDataManager.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 29.11.2022.
//

import Foundation
import CoreData

class CoreDataManager {
    
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
