//
//  YDiskResponse.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 22.11.2022.
//

import UIKit

class DiskResponse: Codable {
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
}
