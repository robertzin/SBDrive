//
//  RecentsPresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 22.11.2022.
//

import UIKit
import Foundation

protocol RecentsMainProtocol {
    func success()
    func failure()
    func imageDownloadingSuccess()
    func imageDownloadingFailure()
    func openDiskItemView(diskItem: DiskItem)
}

protocol RecentsMainPresenterProtocol {
    init(view: RecentsMainProtocol, networkService: NetworkServiceProtocol)
    
    func getDiskItems(url: String)
    func downloadImage(url: String)
    
    func numberOfRowsInSection(at index: Int) -> Int
    func dataForDiskItemAt(_ indexPath: IndexPath) -> DiskItem
    func didSelectDiskItemAt(_ indexPath: IndexPath)
    func mbToKb(size: Int64) -> String
    
    var diskItems: [DiskItem]? { get set }
    var imageCache: NSCache<NSString, UIImage>? { get set }
}

class RecentsMainPresenter: RecentsMainPresenterProtocol {

    var view: RecentsMainProtocol?
    var networkService: NetworkServiceProtocol!
    var diskItems: [DiskItem]?
    var imageCache: NSCache<NSString, UIImage>?
    
    required init(view: RecentsMainProtocol, networkService: NetworkServiceProtocol) {
        self.view = view
        self.networkService = networkService
        imageCache = NSCache()
    }
    
    func getDiskItems(url: String) {
        networkService.getData(url: url, completion: { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let diskItems):
                    // debugPrint("success in Presenter")
                    self.diskItems = diskItems
                    self.view?.success()
                case .failure(let error):
                    debugPrint("error in Presenter: \(error.localizedDescription)")
                    self.diskItems = [DiskItem]()
                    self.view?.failure()
                }
            }
        })
    }
    
    func downloadImage(url: String) {
        if let _ = imageCache?.object(forKey: NSString(string: url)) {
            return
        }
        ImageDownloader.shared.downloadImage(with: url, completionHandler: { image, boolean in
            DispatchQueue.main.async {
                if let image = image {
                    self.imageCache?.setObject(image, forKey: NSString(string: url))
                    self.view?.imageDownloadingSuccess()
                    return
                }
                self.view?.imageDownloadingFailure()
            }
        }, placeholderImage: UIImage(named: "tb_person"))
        
//        networkService.downloadImage(url: url, completion: { [weak self] result in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let image):
////                    print("image cached on url")
//                    self.imageCache?.setObject(image, forKey: NSString(string: url))
//                    self.view?.imageDownloadingSuccess()
//                case .failure(let error):
//                    debugPrint("image downloading failure: \(error.localizedDescription)")
//                    self.view?.imageDownloadingFailure()
//                }
//            }
//        })
    }
    
    func numberOfRowsInSection(at index: Int) -> Int {
        return diskItems?.count ?? 0
    }
    
    func dataForDiskItemAt(_ indexPath: IndexPath) -> DiskItem {
        let diskItem = diskItems?[indexPath.row] ?? DiskItem()
        let imageUrl = diskItem.preview ?? "https://bilgi-sayar.net/wp-content/uploads/2012/01/na.jpg"
        self.downloadImage(url: imageUrl)
        return diskItem
    }
    
    func didSelectDiskItemAt(_ indexPath: IndexPath) {
        guard let diskItem = diskItems?[indexPath.row] else { return }
        view?.openDiskItemView(diskItem: diskItem)
    }
    
    func mbToKb(size: Int64) -> String {
        switch size {
        case let size where size < 1000:
            let newSize = String(format: "%.2f", Double(size) / 1000.00)
            return "\(newSize) \(Constants.Text.kb)"
        case let size where size > 1000 && size < 100000000:
            let newSize = String(format: "%.2f", Double(size) / 1000000.00)
            return "\(newSize) \(Constants.Text.mb)"
        default:
            let newSize = size / 1000000
            return "\(newSize) \(Constants.Text.mb)"
        }
    }
}
