//
//  YDiskItem+CoreDataProperties.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 18.12.2022.
//
//

import Foundation
import CoreData


extension YDiskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YDiskItem> {
        return NSFetchRequest<YDiskItem>(entityName: "YDiskItem")
    }

    @NSManaged public var created: String?
    @NSManaged public var file: String?
    @NSManaged public var md5: String?
    @NSManaged public var media_type: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var modified: String?
    @NSManaged public var name: String?
    @NSManaged public var path: String?
    @NSManaged public var preview: String?
    @NSManaged public var sha256: String?
    @NSManaged public var size: Int64
    @NSManaged public var type: String?
    @NSManaged public var public_key: String?

}

extension YDiskItem : Identifiable {

}
