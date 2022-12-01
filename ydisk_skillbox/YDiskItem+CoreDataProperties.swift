//
//  YDiskItem+CoreDataProperties.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 29.11.2022.
//
//

import Foundation
import CoreData


extension YDiskItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<YDiskItem> {
        return NSFetchRequest<YDiskItem>(entityName: Constants.coreDataEntityName)
    }

    @NSManaged public var file: String?
    @NSManaged public var name: String?
    @NSManaged public var preview: String?
    @NSManaged public var modified: String?
    @NSManaged public var path: String?
    @NSManaged public var media_type: String?
    @NSManaged public var mime_type: String?
    @NSManaged public var created: String?
    @NSManaged public var size: Int64
}

extension YDiskItem : Identifiable {

}
