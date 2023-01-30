//
//  ProfilePresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 06.12.2022.
//

import UIKit

protocol ProfileProtocol {
    func success(dict: [String:AnyObject])
    func pushVC(vc: UIViewController)
}

protocol ProfilePresenterPrototol {
    init(view: ProfileProtocol)
    
    func getDiskInfo()
    func pushVC()
    func performLogOut()
}

class ProfilePresenter: ProfilePresenterPrototol {
    
    var view: ProfileProtocol?
    var networkService: NetworkServiceProtocol!
    var imageDownloader: ImageDownloader!
    var coreDataManager: CoreDataManager!
    var presenterManager: PresenterManager
    
    required init(view: ProfileProtocol) {
        self.view = view
        self.networkService = NetworkService.shared
        self.imageDownloader = ImageDownloader.shared
        self.coreDataManager = CoreDataManager.shared
        self.presenterManager = PresenterManager.shared
    }
    
    func getDiskInfo() {
        if !NetworkMonitor.shared.isConnected {
            var dict: [String: AnyObject] = [:]
            dict["total_space"] = 10000 as AnyObject
            dict["used_space"] = 10000 as AnyObject
            self.view?.success(dict: dict)
            return
        }
        networkService.fileDownload(urlString: Constants.urlStringDiskInfo) { [weak self] result in
            switch result {
            case .success(let data):
                let dict = self?.networkService.JSONtoDictionary(dataString: data!)
                self?.view?.success(dict: dict!)
            case .failure(let error):
                debugPrint("error while downloading data in profile view: \(error.localizedDescription)")
            }
        }
    }
    
    func pushVC() {
        let vc = MainViewController(requestURLstring: Constants.urlStringPublished, header: Constants.Text.uploadedFiles)
        let sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        vc.presenter = MainPresenter(view: vc, comment: Constants.coreDataPublished, sortDescriptors: sortDescriptors)
        view?.pushVC(vc: vc)
    }
    
    func clearAppDirectories() {
        let fm = FileManager()
        fm.clearTmpDirectory()
        fm.clearCacheDirectory()
        fm.clearCookiesDirectory()
    }
    
    func performLogOut() {
        if !NetworkMonitor.shared.isConnected { return }
        do { try KeyChain.shared.deleteToken() }
        catch { print("error while getting token in RecentImageVC: \(error.localizedDescription)") }
        HTTPCookieStorage.shared.cookies?.forEach(HTTPCookieStorage.shared.deleteCookie)
        networkService.revokeToken()
        clearAppDirectories()
        coreDataManager.deleteAllEntities()
        imageDownloader.clearCache()
        presenterManager.show(vc: .login)
    }
}

extension FileManager {
    func clearTmpDirectory() {
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try removeItem(atPath: fileUrl.path)
            }
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func clearCacheDirectory() {
        do {
            let cacheDirURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
            try removeItem(at: cacheDirURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func clearCookiesDirectory() {
        do {
            let libraryDirURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: "")
            let cookiesDirURL = libraryDirURL.appending(path: "Cookies/")
            try removeItem(at: cookiesDirURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
