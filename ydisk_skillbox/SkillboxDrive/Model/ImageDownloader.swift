//
//  ImageDownloader.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 26.11.2022.
//

import UIKit

final class ImageDownloader {
    static let shared = ImageDownloader()
    
    private var cachedImages: [String: UIImage]
    private var imagesDownloadTasks: [String: URLSessionDataTask]
    
    let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)
        
    
    private init() {
        cachedImages = [:]
        imagesDownloadTasks = [:]
    }
    
    func downloadImage(with imageUrlString: String?,
                       completionHandler: @escaping (UIImage?, Bool) -> Void,
                       placeholderImage: UIImage?) {
        guard let imageUrlString = imageUrlString else {
            completionHandler(placeholderImage, true)
            return
        }
        
        if let image = getCachedImageFrom(urlString: imageUrlString) {
            completionHandler(image, true)
        } else {
            guard let url = URL(string: imageUrlString) else {
                completionHandler(placeholderImage, true)
                return
            }
            if let _ = getDataTaskFrom(urlString: imageUrlString) {
                return
            }
            
            var request = URLRequest(url: url)
            request.setValue("OAuth \(Helper.getToken())", forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, _, error) in
                guard let data = data else {
                    return
                }
                
                if let _ = error {
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage, true)
                    }
                    return
                }
                
                let image = UIImage(data: data)
                self.serialQueueForImages.sync(flags: .barrier) {
                    self.cachedImages[imageUrlString] = image
                }
                
                _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
                    self.imagesDownloadTasks.removeValue(forKey: imageUrlString)
                }
                
                DispatchQueue.main.async {
                    completionHandler(image, false)
                }
            }
            imagesDownloadTasks[imageUrlString] = task
            task.resume()
        }
    }
    
    private func getCachedImageFrom(urlString: String) -> UIImage? {
        serialQueueForImages.sync {
            return cachedImages[urlString]
        }
    }

    private func getDataTaskFrom(urlString: String) -> URLSessionTask? {
        serialQueueForDataTasks.sync {
            return imagesDownloadTasks[urlString]
        }
    }
}
