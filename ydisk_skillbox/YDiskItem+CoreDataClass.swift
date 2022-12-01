//
//  YDiskItem+CoreDataClass.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 29.11.2022.
//
//

import Foundation
import CoreData

@objc(YDiskItem)
public class YDiskItem: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.shared.entityForName(entityName: Constants.coreDataEntityName), insertInto: CoreDataManager.shared.context)
    }
    
    func set(diskItem: DiskItem) {
        self.path = diskItem.path
        self.size = diskItem.size!
        self.created = diskItem.created
        self.modified = diskItem.modified
        self.file = diskItem.file
        self.media_type = diskItem.media_type
        self.mime_type = diskItem.mime_type
        self.name = diskItem.name
        self.preview = diskItem.preview
    }
}
