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
    func makeGETrequest(urlString: String, completion: @escaping (Result<DiskItem?, Error>) -> Void)
    func JSONtoDictionary(dataString: Data) -> [String:AnyObject]?
    func fileDownload(urlString: String, completion: @escaping (Result<Data?, Error>) -> Void)
    func fileDelete(path: String, completion: @escaping (Result<Data?, Error>) -> Void)
    func fileRename(oldPath: String, newPath: String, completion: @escaping (Result<DiskItem?, Error>) -> Void)
    func revokeToken()
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
//            debugPrint(String(data: data, encoding: .utf8))
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
        
        do { self.token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in NetworkService: \(error.localizedDescription)") }
        
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("fileDownload success")
                    completion(.success(data))
                default:
                    print("fileDownload failure")
                    debugPrint(String(data: data, encoding: .utf8))
                    completion(.failure(NetworkError.responseStatus))
                }
            }
        }.resume()
    }
    
    func fileDelete(path: String, completion: @escaping (Result<Data?, Error>) -> Void) {
        guard let url = URL(string: Constants.urlStringFileDelete) else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "path", value: path),
            URLQueryItem(name: "permanently", value: "true")
        ]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error )in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("image deleting success")
                    completion(.success(data))
                default:
                    print("image deleting failure")
                    completion(.failure(NetworkError.responseStatus))
                }
            }
        }.resume()
    }
    
    func getHrefForRenaming() {
        
    }
    
    func fileRename(oldPath: String, newPath: String, completion: @escaping (Result<DiskItem?, Error>) -> Void) {
        guard let url = URL(string: Constants.urlStringFileRename) else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "from", value: oldPath),
            URLQueryItem(name: "path", value: newPath)
        ]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let data = data, let jsonDict = self?.JSONtoDictionary(dataString: data) else { return }
            let urlString = jsonDict["href"] as! String
            
            self?.makeGETrequest(urlString: urlString, completion: { result in
                switch result {
                case .success(let diskItem):
                    print("success")
                    completion(.success(diskItem))
                case .failure(let error):
                    print("failure")
                    completion(.failure(error))
                }
            })
        }.resume()
    }
    
    func revokeToken() {
        guard let url = URL(string: Constants.urlStringRevokeToken) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let dataString = "access_token=\(token)&client_id=\(Constants.clientId)&client_secret=\(Constants.clientSecret)"
        let data : Data = dataString.data(using: .utf8)!
        request.httpBody = data
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
    }
}
