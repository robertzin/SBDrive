//
//  Constants.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 07.11.2022.
//

import UIKit

enum Constants {
    
    static var loadingDelay = 1.0
    static let clientId = "8633c79e9a564a2a9839ccc47f3582f8"
    static let clientSecret = "8c1a5eec9c2542a18939e3218ed529da"
    
    static let coreDataEntityName = "YDiskItem"
//    static let coreDataPublishedEntityName = "YDiskPublishedItem"
    
    static let urlStringToken = "https://oauth.yandex.ru/authorize"
    static let urlStringRecents = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded?limit=50"
    static let urlStringPublished = "https://cloud-api.yandex.net/v1/disk/resources/public?limit=10"

    enum Colors {
        static var white: UIColor? {
            UIColor(named: "white")
        }
        static var black: UIColor? {
            UIColor(named: "black")
        }
        static var details: UIColor? {
            UIColor(named: "details")
        }
        static var onboardingDot: UIColor? {
            UIColor(named: "onboardingDot")
        }
        static var accent1: UIColor? {
            UIColor(named: "accent1")
        }
        static var accent2: UIColor? {
            UIColor(named: "accent2")
        }
    }
    
    enum Fonts {
        static var header1: UIFont? {
            UIFont(name: "Graphik-Semibold", size: 26)
        }
        static var header2: UIFont? {
            UIFont(name: "Graphik-Regular", size: 17)
        }
        static var mainBody: UIFont? {
            UIFont(name: "Graphik-Regular", size: 15)
        }
        static var small: UIFont? {
            UIFont(name: "Graphik-Regular", size: 13)
        }
        static var button: UIFont? {
            UIFont(name: "Graphik-Regular", size: 16)
        }
    }
    
    enum Text {
        static let yes = Bundle.main.localizedString(forKey: "Yes", value: "", table: "Localizable")
        static let no = Bundle.main.localizedString(forKey: "No", value: "", table: "Localizable")
        static let logIn = Bundle.main.localizedString(forKey: "Log in", value: "", table: "Localizable")
        static let logOut = Bundle.main.localizedString(forKey: "Log out", value: "", table: "Localizable")
        static let quit = Bundle.main.localizedString(forKey: "Quit", value: "", table: "Localizable")
        static let getStarted = Bundle.main.localizedString(forKey: "Get started", value: "", table: "Localizable")
        static let occupied = Bundle.main.localizedString(forKey: "Occupied", value: "", table: "Localizable")
        static let left = Bundle.main.localizedString(forKey: "Left", value: "", table: "Localizable")
        static let error = Bundle.main.localizedString(forKey: "Error", value: "", table: "Localizable")
        static let dismiss = Bundle.main.localizedString(forKey: "Dismiss", value: "", table: "Localizable")
        static let next = Bundle.main.localizedString(forKey: "Next", value: "", table: "Localizable")
        static let done = Bundle.main.localizedString(forKey: "Done", value: "", table: "Localizable")
        static let cancel = Bundle.main.localizedString(forKey: "Cancel", value: "", table: "Localizable")
        static let refresh = Bundle.main.localizedString(forKey: "Refresh", value: "", table: "Localizable")
        static let recents = Bundle.main.localizedString(forKey: "Recents", value: "", table: "Localizable")
        static let rename = Bundle.main.localizedString(forKey: "Rename", value: "", table: "Localizable")
        static let noInternet = Bundle.main.localizedString(forKey: "No internet connection", value: "", table: "Localizable")
        static let allFiles = Bundle.main.localizedString(forKey: "All files", value: "", table: "Localizable")
        static let emptyDir = Bundle.main.localizedString(forKey: "Directory is empty", value: "", table: "Localizable")
        static let uploadedFiles = Bundle.main.localizedString(forKey: "Uploaded files", value: "", table: "Localizable")
        static let profile = Bundle.main.localizedString(forKey: "Profile", value: "", table: "Localizable")
        static let noUploadedFiles = Bundle.main.localizedString(forKey: "You have no uploaded files", value: "", table: "Localizable")
        static let wantLogOut = Bundle.main.localizedString(forKey: "Are you sure, you want to log out? All local data will be deleted!", value: "", table: "Localizable")
        static let deleteFile = Bundle.main.localizedString(forKey: "Delete the file", value: "", table: "Localizable")
        static let onePlace = Bundle.main.localizedString(forKey: "All files in one place", value: "", table: "Localizable")
        static let offlineAccess = Bundle.main.localizedString(forKey: "Offline access", value: "", table: "Localizable")
        static let shareFiles = Bundle.main.localizedString(forKey: "Share your files with others", value: "", table: "Localizable")
        static let deletingImage = Bundle.main.localizedString(forKey: "This image will be deleted", value: "", table: "Localizable")
        static let fileWillBeDeleted = Bundle.main.localizedString(forKey: "This file will be deleted", value: "", table: "Localizable")
        static let deleteImage = Bundle.main.localizedString(forKey: "Delete the image", value: "", table: "Localizable")
        static let unsupportedType = Bundle.main.localizedString(forKey: "Unsupported file type", value: "", table: "Localizable")
        static let delete = Bundle.main.localizedString(forKey: "Delete", value: "", table: "Localizable")
        static let share = Bundle.main.localizedString(forKey: "Share", value: "", table: "Localizable")
        static let sendFile = Bundle.main.localizedString(forKey: "Send file", value: "", table: "Localizable")
        static let sendLink = Bundle.main.localizedString(forKey: "Send link", value: "", table: "Localizable")
        static let gb = Bundle.main.localizedString(forKey: "gb", value: "", table: "Localizable")
        static let mb = Bundle.main.localizedString(forKey: "mb", value: "", table: "Localizable")
        static let kb = Bundle.main.localizedString(forKey: "kb", value: "", table: "Localizable")
    }
    
    enum Image {
        static let sbDrive = UIImage(named: "sbDrive")
        static let onboarding1 = UIImage(named: "onboarding1")
        static let onboarding2 = UIImage(named: "onboarding2")
        static let onboarding3 = UIImage(named: "onboarding3")
        static let equal = UIImage(named: "equal")
        static let chevronR = UIImage(named: "chevronRight")
    }
}
