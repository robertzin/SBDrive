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
}

class NetworkService: NetworkServiceProtocol {
    
    enum NetworkError: Error {
        case wrongURLString
        case wrongURL
        case responseStatus
    }
    
    private var token = ""
    static var shared = NetworkService()
    private var task: URLSessionDataTask!
    
    init() {
        do { token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in NetworkService: \(error.localizedDescription)") }
    }
    
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
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
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
    
    func makeGETrequest(urlString: String, completion: @escaping (Result<DiskItem?, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(.failure(error))
                return
            }
            do {
                let diskItem = try JSONDecoder().decode(DiskItem.self, from: data)
                completion(.success(diskItem))
            } catch {
                completion(.failure(error))
                debugPrint("parisng error!")
            }
        }.resume()
    }
    
    func JSONtoDictionary(dataString: Data) -> [String:AnyObject]? {
        do {
            let json = try JSONSerialization.jsonObject(with: dataString, options: .mutableContainers) as? [String:AnyObject]
            return json
        } catch {
            debugPrint("Error while converting data string to dictionary")
        }
        return [:]
    }
    
    func fileDownload(urlString: String, completion: @escaping (Result<Data?, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            if let error = error {
                debugPrint(error.localizedDescription)
                completion(.failure(error))
                return
            }
            completion(.success(data))
        }.resume()
    }
}
