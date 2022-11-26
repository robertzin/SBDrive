//
//  NetworkServices.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 22.11.2022.
//

import Foundation
import UIKit

protocol NetworkServiceProtocol: AnyObject {
    func getData(url: String, completion: @escaping (Result<[DiskItem]?, Error>) -> Void)
    func downloadImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}

class NetworkService: NetworkServiceProtocol {
    
    private var task: URLSessionDataTask!
    
    func getData(url: String, completion: @escaping (Result<[DiskItem]?, Error>) -> Void) {
        guard let url = URL(string: url) else { return }
//        debugPrint(url)
        
//        var components = URLComponents(string: url)
//        components?.queryItems = [
//            URLQueryItem(name: "preview_size", value: "75x75"),
//            URLQueryItem(name: "preview_crop", value: "true")
//        ]
//        guard let url = components?.url else { return }
        
        var request = URLRequest(url: url)
        request.setValue("OAuth \(Helper.getToken())", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else { return }
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(.failure(error))
                return
            }
            do {
                let diskItems = try JSONDecoder().decode(DiskResponse.self, from: data)
//                debugPrint("success in networkService")
                completion(.success(diskItems.items))
            } catch {
                completion(.failure(error))
                debugPrint("parisng error!")
            }
        }.resume()
    }
    
    func downloadImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        ImageDownloader.shared.downloadImage(with: url, completionHandler: { image, inCache in
            DispatchQueue.main.async {
                
            }
        }, placeholderImage: UIImage(named: "tb_person"))
//        guard let remoteImageURL = URL(string: url) else { return }
//        var request = URLRequest(url: remoteImageURL)
//        request.setValue("OAuth \(Helper.getToken())", forHTTPHeaderField: "Authorization")
//        task = URLSession.shared.dataTask(with: remoteImageURL) { data, _, error in
//            if let error = error {
//                debugPrint(error.localizedDescription)
//                completion(.failure(error))
//                return
//            }
//            do {
////                debugPrint(String(data: data!, encoding: .utf8))
//                if let downloadedImage = UIImage(data: data!) {
//                    completion(.success(downloadedImage))
//                } else {
//                    debugPrint("completion failured!")
//                }
//            }
//        }
//        task.resume()
    }
}
