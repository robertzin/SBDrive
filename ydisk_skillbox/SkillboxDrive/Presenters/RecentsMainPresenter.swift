//
//  RecentsMainPresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 22.11.2022.
//

import UIKit
import Foundation
import CoreData

protocol RecentsMainProtocol {
    func success()
    func failure()
    func imageDownloadingSuccess()
    func imageDownloadingFailure()
    func openDiskItemView(vc: UIViewController)
    func presentAlert(alert: UIAlertController)
}

protocol RecentsMainPresenterProtocol {
 
    init(view: RecentsMainProtocol, networkService: NetworkServiceProtocol)
    
    func getDiskItems(url: String)
    func getImageForCell(url: String) -> UIImage
    func downloadImage(url: String)
    
    func numberOfRowsInSection(at section: Int) -> Int
    func dataForDiskItemAt(_ indexPath: IndexPath) -> YDiskItem
    func didSelectDiskItemAt(_ indexPath: IndexPath)
    func mbToKb(size: Int64) -> String
    
    var imageCache: NSCache<NSString, UIImage>? { get set }
}

class RecentsMainPresenter: RecentsMainPresenterProtocol {

    var view: RecentsMainProtocol?
    var networkService: NetworkServiceProtocol!
    var imageCache: NSCache<NSString, UIImage>?
    
    required init(view: RecentsMainProtocol, networkService: NetworkServiceProtocol) {
        self.view = view
        self.networkService = networkService
        self.imageCache = ImageDownloader.shared.cachedImages
    }
    
    func getDiskItems(url: String) {
        networkService.getData(url: url, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let diskItems):
                     debugPrint("getDiskItems success")
//                    CoreDataManager.shared.deleteIfNotPresented(diskItemArray: diskItems!)
                    diskItems?.forEach({ diskItem in
//                        print("downloaded element: \(diskItem.name!)")
                        if CoreDataManager.shared.isUnique(diskItem: diskItem) {
                            let YdiskItem = YDiskItem()
                            YdiskItem.set(diskItem: diskItem)
                        }
                    })
//                    CoreDataManager.shared.deleteAllEntities()
                    self.view?.success()
                case .failure(let error):
                    debugPrint("getDiskItems failure: \(error.localizedDescription)")
                    self.view?.failure()
                }
            }
        })
    }
    
    func downloadImage(url: String) {
        if let _ = imageCache?.object(forKey: NSString(string: url)) {
            return
        }
        ImageDownloader.shared.downloadImage(with: url, completion: { result in
            switch result {
            case .success(let image):
                self.imageCache?.setObject(image, forKey: NSString(string: url))
                self.view?.imageDownloadingSuccess()
            case (.failure(let error)):
                debugPrint("image downloading failure: \(error.localizedDescription)")
               self.view?.imageDownloadingFailure()
            }
        }, placeholderImage: UIImage(named: "tb_person"))
    }
    
    func getImageForCell(url: String) -> UIImage {
        var retImage = UIImage()
        ImageDownloader.shared.downloadImage(with: url, completion: { result in
            switch result {
            case .success(let image):
                retImage = image
            case (.failure(let error)):
                debugPrint("image downloading failure: \(error.localizedDescription)")
               self.view?.imageDownloadingFailure()
            }
        }, placeholderImage: UIImage(named: "tb_person"))
        return retImage
    }
    
    func numberOfRowsInSection(at section: Int) -> Int {
        guard let sections = CoreDataManager.shared.fetchResultController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func dataForDiskItemAt(_ indexPath: IndexPath) -> YDiskItem {
        if (CoreDataManager.shared.fetchResultController.sections) != nil {
            return CoreDataManager.shared.fetchResultController.object(at: indexPath) as! YDiskItem
        }
        return YDiskItem()
    }
    
    func didSelectDiskItemAt(_ indexPath: IndexPath) {
        let diskItem = CoreDataManager.shared.fetchResultController.object(at: indexPath) as! YDiskItem
        
        switch diskItem.mime_type {
        case let str where str!.contains("document"):
            let vc = RecentsDetailsViewController(diskItem: diskItem, type: CoreDataManager.elementType.document)
            view?.openDiskItemView(vc: vc)
        case let str where str!.contains("pdf"):
            let vc = RecentsDetailsViewController(diskItem: diskItem, type: CoreDataManager.elementType.pdf)
            view?.openDiskItemView(vc: vc)
        case let str where str!.contains("image"):
            let vc = RecentsDetailsViewController(diskItem: diskItem, type: CoreDataManager.elementType.image)
            view?.openDiskItemView(vc: vc)
        default:
            let alert = UIAlertController(title: Constants.Text.error, message: Constants.Text.unsupportedType, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Text.dismiss, style: .cancel))
            view?.presentAlert(alert: alert)
        }
    }
    
    func mbToKb(size: Int64) -> String {
        size.mbToKb()
    }
}

extension Int64 {
    func mbToKb() -> String {
        switch self {
        case let size where size < 1000:
            let newSize = String(format: "%.2f", Double(size) / 1000.00)
            return "\(newSize) \(Constants.Text.kb)"
        case let size where size > 1000 && size < 100000000:
            let newSize = String(format: "%.2f", Double(size) / 1000000.00)
            return "\(newSize) \(Constants.Text.mb)"
        default:
            let newSize = self / 1000000
            return "\(newSize) \(Constants.Text.mb)"
        }
    }
}
