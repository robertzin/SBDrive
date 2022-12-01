//
//  ImageDownloader.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 26.11.2022.
//

import UIKit

final class ImageDownloader {
    
    static let shared = ImageDownloader()
    
    private var token = ""
    var cachedImages: NSCache<NSString, UIImage>
    var imagesDownloadTasks: NSCache<NSString, URLSessionDataTask>
    
    let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)
    
    private init() {
        do { try token = KeyChain.shared.getToken() }
        catch { print("failed to get token in ImageDownloader: \(error.localizedDescription)") }
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
            print("url: \(imageUrlString)")
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
//        request.setValue("OAuth \(self.token!)", forHTTPHeaderField: "Authorization")
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
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
                print(String(data: data, encoding: .utf8))
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
    case wrongURLString // = "ImageDownloader error: wrong URL String"
    case wrongURL // = "ImageDownloader error: wrong URL"
    case UIImageError // = "ImageDownloader error: UIImage converting error"
}
