//
//  RenamePresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 17.12.2022.
//

import UIKit

protocol RenameProtocol {
    func dismissVC()
}

protocol RenamePresenterProtocol {
    
    init(view: RenameProtocol, networkService: NetworkServiceProtocol)
    var token: String { get }
    func getToken()
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    
    func renameFile(diskItem: YDiskItem, newTitle: String)
    func setNewValuesToFile(oldDiskItem: YDiskItem, newDiskItem: DiskItem)
    func makeNotification(diskItem: DiskItem)
}

final class RenamePresenter: RenamePresenterProtocol {
    
    var view: RenameProtocol?
    var networkService: NetworkServiceProtocol!
    var imageDownloader: ImageDownloader!
    
    var token = ""
    
    required init(view: RenameProtocol, networkService: NetworkServiceProtocol) {
        self.view = view
        self.imageDownloader = ImageDownloader.shared
        self.networkService = networkService
    }
    
    func getToken() {
        do { self.token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in RecentImageVC: \(error.localizedDescription)") }
    }
    
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        imageDownloader.downloadImage(with: urlString, completion: { result in
            switch result {
            case .success(let image):
                completion(.success(image))
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func renameFile(diskItem: YDiskItem, newTitle: String) {
        let idx = diskItem.path?.lastIndex(of: "/")
        guard let oldPath = diskItem.path else { return }
        let newPath = String(diskItem.path![...idx!]).appending(newTitle)
        
        networkService.fileRename(oldPath: oldPath, newPath: newPath) { [weak self] result in
            switch result {
            case .success(let newDiskItem):
                DispatchQueue.main.async {
                    self?.setNewValuesToFile(oldDiskItem: diskItem, newDiskItem: newDiskItem!)
                    self?.makeNotification(diskItem: newDiskItem!)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func setNewValuesToFile(oldDiskItem: YDiskItem, newDiskItem: DiskItem) {
        let diskItemToChange = CoreDataManager.shared.context.object(with: oldDiskItem.objectID) as! YDiskItem
//        guard let comment = oldDiskItem.comment else { return }
        diskItemToChange.set(diskItem: newDiskItem)
        CoreDataManager.shared.saveContext()
    }
    
    func makeNotification(diskItem: DiskItem) {
        DispatchQueue.main.async { [weak self] in
            let dict: [String: String] = [
                "name": diskItem.name!,
                "modified": (diskItem.modified?.toDate())!
            ]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue:  "PeformAfterPresenting"), object: nil, userInfo: dict)
            self?.view?.dismissVC()
        }
    }
}
