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
    
    func getData()
    func pushVC()
    func performLogOut()
}

class ProfilePresenter: ProfilePresenterPrototol {
    
    var view: ProfileProtocol?
    var networkService: NetworkServiceProtocol!
    var imageDownloader: ImageDownloader!
    var coreDataManager: CoreDataManager!
    
    required init(view: ProfileProtocol) {
        self.view = view
        self.networkService = NetworkService.shared
        self.imageDownloader = ImageDownloader.shared
        self.coreDataManager = CoreDataManager.shared
    }

    func getData() {
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
        let vc = PublishedMainViewController()
        vc.presenter = PublishedMainPresenter(view: vc, networkService: NetworkService.shared)
        view?.pushVC(vc: vc)
    }
    
    func performLogOut() {
        do { try KeyChain.shared.deleteToken() }
        catch { print("error while getting token in RecentImageVC: \(error.localizedDescription)") }
        networkService.revokeToken()
        coreDataManager.deleteAllEntities()
        ImageDownloader.shared.clearCache()
        PresenterManager.shared.show(vc: .login)
    }
}
