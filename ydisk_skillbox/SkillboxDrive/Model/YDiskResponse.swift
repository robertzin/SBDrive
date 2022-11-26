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
    var modified: String?
}
