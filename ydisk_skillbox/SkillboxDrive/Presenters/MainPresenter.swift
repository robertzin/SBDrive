//
//  MainPresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.01.2023.
//

import UIKit
import CoreData

protocol MainProtocol {
    func success()
    func failure()
    func imageDownloadingSuccess()
    func imageDownloadingFailure()
    func openDiskItemView(vc: UIViewController)
    func presentAlert(alert: UIAlertController)
}

protocol MainPresenterProtocol {
    init(view: MainProtocol, comment: String)
    
    func getDiskItems(url: String)
    func getImageForCell(diskItem: YDiskItem) -> UIImage
    func downloadImage(url: String)
    func alert(indexPath: IndexPath)
    
    func numberOfRowsInSection(at section: Int) -> Int
    func dataForDiskItemAt(_ indexPath: IndexPath) -> YDiskItem
    func didSelectDiskItemAt(_ indexPath: IndexPath)
    func mbToKb(size: Int64) -> String
    func performPaginate(url: String)
    
    var isConnected: Bool { get }
    var imageCache: NSCache<NSString, UIImage>? { get set }
    var coreDataManager: CoreDataManager! { get }
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> { get }
}

class MainPresenter: MainPresenterProtocol {

    var view: MainProtocol?
    var networkService: NetworkServiceProtocol!
    var imageDownloader: ImageDownloader!
    
    var isConnected: Bool
    var imageCache: NSCache<NSString, UIImage>?
    var coreDataManager: CoreDataManager!
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>
    
    var maxLimitExceeded: Bool
    var currentOffset: Int16 = 0
    var comment: String
    
    required init(view: MainProtocol, comment: String = "") {
        self.view = view
        self.networkService = NetworkService.shared
        self.coreDataManager = CoreDataManager.shared
        self.imageDownloader = ImageDownloader.shared
        self.imageCache = imageDownloader.cachedImages
        self.maxLimitExceeded = false
        
        self.comment = comment
        self.fetchResultController = coreDataManager.fetchResultController(comment: comment)
        self.isConnected = NetworkMonitor.shared.isConnected
    }
    
    func getDiskItems(url: String) {
        if !NetworkMonitor.shared.isConnected {
            self.view?.success()
            return
        }
        networkService.getData(url: url, offset: 0, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let tuple):
//                    debugPrint("getDiskItems success: \(tuple.0?.count)")
//                    coreDataManager.deleteIfNotPresented(diskItemArray: diskItems!)
                    tuple.0?.forEach({ diskItem in
//                        debugPrint("downloaded element: \(diskItem.name!)")
//                        if self.coreDataManager.isUnique(diskItem: diskItem) {
//                            print("is unique")
                            diskItem.offset = tuple.1
                            let YdiskItem = YDiskItem()
                            YdiskItem.set(diskItem: diskItem, comment: self.comment)
//                            print("\(YdiskItem.name) - \(YdiskItem.public_key)")
//                        }
                    })
//                    self.coreDataManager.deleteAllEntities()
                    self.view?.success()
                case .failure(let error):
                    debugPrint("getDiskItems failure: \(error.localizedDescription)")
                    self.view?.failure()
                }
            }
        })
    }
    
    func getMoreData(url: String, offset: Int16) {
        if maxLimitExceeded == true || currentOffset == offset { return }
        currentOffset = offset
        networkService.getData(url: url, offset: offset, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let tuple):
//                    debugPrint("get more disk items success")
//                    CoreDataManager.shared.deleteIfNotPresented(diskItemArray: diskItems!)
                    tuple.0?.forEach({ diskItem in
//                        if self.coreDataManager.isUnique(diskItem: diskItem) {
                            diskItem.offset = tuple.1
                            let YdiskItem = YDiskItem()
                            YdiskItem.set(diskItem: diskItem, comment: self.comment)
//                            print("\(YdiskItem.name) - \(YdiskItem.public_key)")
//                        }
                    })
                    if tuple.0?.count == 0 {
                        self.maxLimitExceeded = true
                        self.view?.failure()
                    }
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
        imageDownloader.downloadImage(with: url, completion: { result in
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
        var retImage = UIImage()
        imageDownloader.downloadImage(with: url, completion: { result in
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
        guard let sections = fetchResultController.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func dataForDiskItemAt(_ indexPath: IndexPath) -> YDiskItem {
//        debugPrint("dataForDiskItemAt")
        if (fetchResultController.sections) != nil {
            let diskItem = fetchResultController.object(at: indexPath) as! YDiskItem
            let url = diskItem.preview ?? "https://bilgi-sayar.net/wp-content/uploads/2012/01/na.jpg"
            downloadImage(url: url)
            return diskItem
        }
        return YDiskItem()
    }
    
    func didSelectDiskItemAt(_ indexPath: IndexPath) {
        let diskItem = fetchResultController.object(at: indexPath) as! YDiskItem
        
        if diskItem.type == "dir" {
            guard let path = diskItem.path else { return }
            let urlString = Constants.urlStringDirContent.appending(path)
            print(urlString)
            
            let idx = path.lastIndex(of: "/")!
            let header = String(path[path.index(idx, offsetBy: 1)...])
            
            let vc = MainViewController(requestURLstring: urlString, header: header)
            vc.presenter = MainPresenter(view: vc, comment: path)
            view?.openDiskItemView(vc: vc)
            return
        }
        
        switch diskItem.mime_type {
        case let str where str!.contains("document"):
            let vc = DetailsViewController(diskItem: diskItem, type: CoreDataManager.elementType.document)
            vc.presenter = DetailsPresenter(view: vc)
            view?.openDiskItemView(vc: vc)
        case let str where str!.contains("pdf"):
            let vc = DetailsViewController(diskItem: diskItem, type: CoreDataManager.elementType.pdf)
            vc.presenter = DetailsPresenter(view: vc)
            view?.openDiskItemView(vc: vc)
        case let str where str!.contains("image"):
            let vc = DetailsViewController(diskItem: diskItem, type: CoreDataManager.elementType.image)
            vc.presenter = DetailsPresenter(view: vc)
            view?.openDiskItemView(vc: vc)
        default:
            let alert = UIAlertController(title: Constants.Text.error, message: Constants.Text.unsupportedType, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.Text.dismiss, style: .cancel))
            view?.presentAlert(alert: alert)
        }
    }
    
    func performPaginate(url: String) {
        guard let sections = self.fetchResultController.sections else { return }
        let offset = Int16(sections[0].numberOfObjects)
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            if !self.maxLimitExceeded {
                //            debugPrint("getting more data")
                self.getMoreData(url: url, offset: offset)
            }
            else {
                print("no items left")
                self.view?.failure()
            }
        }
    }

    func alert(indexPath: IndexPath) {
        if (self.fetchResultController.sections) == nil { return }
        let diskItem = self.fetchResultController.object(at: indexPath) as! YDiskItem
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: diskItem.name!, attributes: msgAttributes as [NSAttributedString.Key : Any])
        let deleteAction = UIAlertAction(title: Constants.Text.deleteFile, style: .destructive, handler: { [weak self]_ in
            
            guard let path = diskItem.path else { return }
            self?.networkService.fileDelete(path: path, completion: { result in
                DispatchQueue.main.async { [weak self] in
                    self?.coreDataManager.context.delete(diskItem)
                    self?.coreDataManager.saveContext()
                }
            })
        })
        
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)
        
        alert.view.tintColor = .black
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        view?.presentAlert(alert: alert)
    }
    
    func mbToKb(size: Int64) -> String {
        size.mbToKb()
    }
}


extension Int64 {
    func mbToKb() -> String {
        switch self {
        case let size where size < 10000:
            let newSize = String(format: "%.2f", Double(size) / 1000.00)
            return "\(newSize) \(Constants.Text.kb)"
        case let size where size > 10000 && size < 100000000:
            let newSize = String(format: "%.2f", Double(size) / 1000000.00)
            return "\(newSize) \(Constants.Text.mb)"
        case let size where size > 100000000:
            let newSize = String(format: "%.2f", Double(size) / 100000000.00)
            return "\(newSize) \(Constants.Text.gb)"
        default:
            let newSize = self / 1000000
            return "\(newSize) \(Constants.Text.mb)"
        }
    }
}
