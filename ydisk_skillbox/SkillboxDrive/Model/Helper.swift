//
//  Helper.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 21.11.2022.
//

import UIKit

class Helper {
    
    static var defaults = UserDefaults()
    
    static func getToken() -> String {
        defaults.string(forKey: "token") ?? ""
    }
    
    static func setToken(token: String) {
        defaults.set(token, forKey: "token")
    }
    
    static func eraseToken() {
        defaults.removeObject(forKey: "token")
    }
}
