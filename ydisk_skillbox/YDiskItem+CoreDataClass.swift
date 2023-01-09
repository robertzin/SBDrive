//
//  YDiskItem+CoreDataClass.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.01.2023.
//
//

import Foundation
import CoreData

@objc(YDiskItem)
public class YDiskItem: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.shared.entityForName(entityName: Constants.coreDataEntityName), insertInto: CoreDataManager.shared.context)
    }
    
    func set(diskItem: DiskItem, comment: String) {
        self.md5 = diskItem.md5
        self.name = diskItem.name
        self.offset = diskItem.offset ?? -1
        self.preview = diskItem.preview
        self.mime_type = diskItem.mime_type
        self.media_type = diskItem.media_type
        self.path = diskItem.path
        self.file = diskItem.file
        self.created = diskItem.created
        self.modified = diskItem.modified
        self.size = diskItem.size ?? 0
        self.sha256 = diskItem.sha256
        self.type = diskItem.type
        self.public_key = diskItem.public_key
        self.comment = comment
    }
}
