//
//  YDiskResponse.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 22.11.2022.
//

import UIKit

class DirectoryDiskResponse: Codable {
    let public_key: String?
    let path: String?
    let _embedded: DiskResponse?
    let limit: Int16?
    let offset: Int16?
    let total: Int16?
}

class DiskResponse: Codable {
    let offset: Int16?
    let items: [DiskItem]?
}

class DiskItem: Codable {
    var name: String?
    var preview: String?
    var size: Int64?
    var created: String?
    var modified: String?
    var path: String?
    var media_type: String?
    var mime_type: String?
    var file: String?
    var md5: String?
    var sha256: String?
    var type: String?
    var public_key: String?
    var offset: Int16?
}
