//
//  ImageDownloader.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 26.11.2022.
//

import UIKit

final class ImageDownloader {
    
    static let shared = ImageDownloader()
    
    var cachedImages: NSCache<NSString, UIImage>
    var imagesDownloadTasks: NSCache<NSString, URLSessionDataTask>
    
    let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)
    
    private init() {
        cachedImages = NSCache<NSString, UIImage>()
        imagesDownloadTasks = NSCache<NSString, URLSessionDataTask>()
    }

    func downloadImage(with imageUrlString: String?,
                       completion: @escaping (Result<UIImage, Error>) -> Void,
                       placeholderImage: UIImage?) {
        guard let imageUrlString = imageUrlString else {
            completion(.failure(ImageDownloaderError.wrongURLString))
            return
        }
        guard let url = URL(string: imageUrlString) else {
            completion(.failure(ImageDownloaderError.wrongURL))
            return
        }
        if let _ = getDataTaskFrom(urlString: imageUrlString) {
            return
        }
        if let image = getCachedImageFrom(urlString: imageUrlString) {
            completion(.success(image))
        }
        
        var request = URLRequest(url: url)
        request.setValue("OAuth \(Helper.getToken())", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data else {
                return
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(ImageDownloaderError.UIImageError))
                return
            }
            
            self.serialQueueForImages.sync(flags: .barrier) {
                self.cachedImages.setObject(image, forKey: NSString(string: imageUrlString))
            }
            
            let _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
                self.imagesDownloadTasks.removeObject(forKey: NSString(string: imageUrlString))
            }
            
            DispatchQueue.main.async {
                completion(.success(image))
            }
        }
        imagesDownloadTasks.setObject(task, forKey: NSString(string: imageUrlString))
        task.resume()
    }
    
    private func getCachedImageFrom(urlString: String) -> UIImage? {
         serialQueueForImages.sync {
             return cachedImages.object(forKey: NSString(string: urlString))
         }
     }
    
    private func getDataTaskFrom(urlString: String) -> URLSessionTask? {
        serialQueueForDataTasks.sync {
            return imagesDownloadTasks.object(forKey: NSString(string: urlString))
        }
    }
}

enum ImageDownloaderError: Error {
    case wrongURLString
    case wrongURL
    case UIImageError
}
