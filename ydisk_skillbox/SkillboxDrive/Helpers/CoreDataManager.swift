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

    func fetchResultController(comment: String) -> NSFetchedResultsController<YDiskItem> {
        let fetchRequest = NSFetchRequest<YDiskItem>(entityName: Constants.coreDataEntityName)
        let predicate = NSPredicate(format: "comment == %@", comment)
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        print("comment: \(comment), predicate: \(predicate)")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 20
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultController
    }
    
    func fetchResultsController(type: String, sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController<YDiskItem> {
        let fetchRequest = NSFetchRequest<YDiskItem>(entityName: Constants.coreDataEntityName)
        let predicate = NSPredicate(format: "\(type) == YES")
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 20
        let fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchResultController
    }
    
    func getFetchResultsController(comment: String, sortDescriptors: [NSSortDescriptor]) -> NSFetchedResultsController<YDiskItem> {
        switch comment {
        case Constants.coreDataRecents:
            return fetchResultsController(type: "recents", sortDescriptors: sortDescriptors)
        case Constants.coreDataPublished:
            return fetchResultsController(type: "published", sortDescriptors: sortDescriptors)
        case Constants.coreDataAllFiles:
            return fetchResultsController(type: "allFiles", sortDescriptors: sortDescriptors)
        default:
            return fetchResultController(comment: comment)
        }
    }
    
    func count() -> Int {
        let fetchRequest = NSFetchRequest<YDiskItem>(entityName: Constants.coreDataEntityName)
        do {
            let count = try context.count(for: fetchRequest)
            return count
        } catch { print(error.localizedDescription) }
        return -1
    }
    
    func isOnFewViews(diskItem: YDiskItem) {
        let fetchRequest = NSFetchRequest<YDiskItem>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(fetchRequest)
            guard let coreDataElement = allData.first(where: { $0.name == diskItem.name }) else { return }
            if diskItem.recents == true && coreDataElement.recents == false {
                //                    debugPrint("recents is true now at \(String(describing: diskItem.name))")
                coreDataElement.recents = diskItem.recents
            } else if diskItem.published == true && coreDataElement.published == false {
                //                    debugPrint("pubished is true now at \(String(describing: diskItem.name))")
                coreDataElement.published = diskItem.published
            } else if diskItem.allFiles == true && coreDataElement.allFiles == false {
                //                    debugPrint("allFiles is true now from \(diskItem.name!) to \(coreDataElement.name!)")
                coreDataElement.allFiles = diskItem.allFiles
            } else if diskItem.comment != nil && diskItem.comment != coreDataElement.comment {
                //                    debugPrint("comment \(String(describing: diskItem.comment)) is assigned now at \(String(describing: diskItem.name))")
                coreDataElement.comment = diskItem.comment
            }
        } catch {
            print("error while isOnFewViews is checked: \(error.localizedDescription)")
        }
    }
    
    func deleteIfNotPresented(diskItemArray: [DiskItem]) {
        let idsArray = diskItemArray.map { $0.name }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(fetchRequest) as! [YDiskItem]
            allData.forEach { yDiskItem in
                if !idsArray.contains(yDiskItem.name) {
                    debugPrint("deleted from CoreData when not presented: \(String(describing: yDiskItem.name))")
                    context.delete(yDiskItem)
                }
            }
        } catch {
            print("error performing deletion and inserting: \(error.localizedDescription)")
        }
    }
    
    func printElement(diskItem: YDiskItem) {
        print("""
            - name: \(diskItem.name!)
            - recents: \(diskItem.recents)
            - published: \(diskItem.published)
            - allfiles: \(diskItem.allFiles)
            - comment: \(String(describing: diskItem.comment))
            """)
    }
    
    func printData() {
        let fetchRequest = YDiskItem.fetchRequest()
        do {
            let allData = try context.fetch(fetchRequest)
            for object in allData { print("""
                - name: \(object.name!)
                - recents: \(object.recents)
                - published: \(object.published)
                - allfiles: \(object.allFiles)
                - comment: \(String(describing: object.comment))
                """) }
        } catch {
            print("error while printing IDs: \(error.localizedDescription)")
        }
    }
    
    func deleteAllEntities() {
        let deleteRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.coreDataEntityName)
        do {
            let allData = try context.fetch(deleteRequest)
            for object in allData as! [YDiskItem] {
                print("deleting from CoreData: \(object.name)")
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
