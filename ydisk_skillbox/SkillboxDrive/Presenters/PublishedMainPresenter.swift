//
//  PublishedMainPresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 06.12.2022.
//

import UIKit

protocol PublishedMainProtocol {
    func success()
    func failure()
    func imageDownloadingSuccess()
    func imageDownloadingFailure()
    func openDiskItemView(vc: UIViewController)
    func presentAlert(alert: UIAlertController)
}

protocol PublishedMainPresenterProtocol {
    init(view: PublishedMainProtocol, networkService: NetworkServiceProtocol)
    
    func getDiskItems(url: String)
    func getImageForCell(diskItem: YDiskItem) -> UIImage
    func downloadImage(url: String)
    func alert(indexPath: IndexPath)
    
    func numberOfRowsInSection(at section: Int) -> Int
    func dataForDiskItemAt(_ indexPath: IndexPath) -> YDiskItem
    func didSelectDiskItemAt(_ indexPath: IndexPath)
    func mbToKb(size: Int64) -> String
    
    var imageCache: NSCache<NSString, UIImage>? { get set }
}

class PublishedMainPresenter: PublishedMainPresenterProtocol {
    var view: PublishedMainProtocol?
    var networkService: NetworkServiceProtocol!
    var imageCache: NSCache<NSString, UIImage>?

    required init(view: PublishedMainProtocol, networkService: NetworkServiceProtocol) {
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
//                            print("\(YdiskItem.name) - \(YdiskItem.public_key)")
//                            print("\(YdiskItem.name) - \(YdiskItem.public_key)")
                        }
                    })
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
    
    func getImageForCell(diskItem: YDiskItem) -> UIImage {
        if diskItem.type == "dir" { return UIImage(named: "dirPreview")! }
        let url = diskItem.preview ?? "https://bilgi-sayar.net/wp-content/uploads/2012/01/na.jpg"
//        if let img = imageCache?.object(forKey: NSString(string: url)) {
//            return img
//        }
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
        guard let sections = CoreDataManager.shared.fetchPublishedResultController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func dataForDiskItemAt(_ indexPath: IndexPath) -> YDiskItem {
        if (CoreDataManager.shared.fetchPublishedResultController.sections) != nil {
            let diskItem = CoreDataManager.shared.fetchPublishedResultController.object(at: indexPath) as! YDiskItem
            let url = diskItem.preview ?? "https://bilgi-sayar.net/wp-content/uploads/2012/01/na.jpg"
            downloadImage(url: url)
            return diskItem
        }
        print("returning nil")
        return YDiskItem()
    }
    
    func didSelectDiskItemAt(_ indexPath: IndexPath) {
        
    }
    
    func mbToKb(size: Int64) -> String {
        size.mbToKb()
    }
    
    func alert(indexPath: IndexPath) {
        if (CoreDataManager.shared.fetchPublishedResultController.sections) == nil { return }
        let diskItem = CoreDataManager.shared.fetchPublishedResultController.object(at: indexPath) as! YDiskItem
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: diskItem.name!, attributes: msgAttributes as [NSAttributedString.Key : Any])
        let deleteAction = UIAlertAction(title: Constants.Text.deleteFile , style: .destructive, handler: { [weak self]_ in
            CoreDataManager.shared.context.delete(diskItem)
            self?.view?.success()
//            self?.deleteImage {
//                DispatchQueue.main.async { [weak self] in
//                    CoreDataManager.shared.context.delete(self!.diskItem)
//                    CoreDataManager.shared.saveContext()
//                    self?.navigationController?.popViewController(animated: true)
//                }
//            }
        })
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)
        
        alert.view.tintColor = .black
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        view?.presentAlert(alert: alert)
    }
}
