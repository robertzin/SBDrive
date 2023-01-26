//
//  NetworkServices.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 22.11.2022.
//

import Foundation
import UIKit
import Network

protocol NetworkServiceProtocol: AnyObject {
    func getData(url: String, offset: Int16, completion: @escaping (Result<([DiskItem]?, Int16?), Error>) -> Void)
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
        case noInternetConnection
    }
    
    private var token = ""
    private var task: URLSessionDataTask!
    static var shared = NetworkService()
    
    init() {
        do { token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in NetworkService: \(error.localizedDescription)") }
    }
    
    func getData(url: String, offset: Int16 = 0, completion: @escaping (Result<([DiskItem]?, Int16?), Error>) -> Void) {
        var isDirectory: Bool = false
        
        var components = URLComponents(string: url)
        components?.queryItems = []
        if url.contains("path=") {
            isDirectory = true
            let idx = url.lastIndex(of: "=")!
            let path = String(url[url.index(idx, offsetBy: 1)...])
            
            components?.queryItems?.append(URLQueryItem(name: "path", value: path))
        }

        components?.queryItems?.append(URLQueryItem(name: "limit", value: "\(Constants.receivingAPIelemetsLimit)"))
        components?.queryItems?.append(URLQueryItem(name: "preview_crop", value: "true"))
        components?.queryItems?.append(URLQueryItem(name: "preview_size", value: "55x55"))
        
//        debugPrint("offset: \(offset)")
        if offset > 0 {
            components?.queryItems?.append(URLQueryItem(name: "offset", value: "\(offset)"))
        }
        guard let url = components?.url else { return }
        
        var request = URLRequest(url: url)
//        debugPrint("request: \(request)")
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
//            debugPrint(String(data: data, encoding: .utf8))
            if let response = response as? HTTPURLResponse {
//                debugPrint("response.status code: \(response.statusCode)")
                switch response.statusCode {
                case 200..<300:
                    do {
                        if isDirectory == true {
                            let dirDiskResponse = try JSONDecoder().decode(DirectoryDiskResponse.self, from: data)
//                            debugPrint("diskItems count: \(dirDiskResponse._embedded?.items?.count)")
                            completion(.success((dirDiskResponse._embedded?.items, dirDiskResponse.offset)))
                            return
                        }
                        
                        let diskResponse = try JSONDecoder().decode(DiskResponse.self, from: data)
                        debugPrint("success in networkService. diskItems count: \(diskResponse.items?.count)")
                        completion(.success((diskResponse.items, diskResponse.offset)))
                    } catch {
                        completion(.failure(error))
                        debugPrint("parisng error!")
                    }
                default:
                    print("response status: \(response.statusCode)")
                    completion(.failure(NetworkError.responseStatus))
                }
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
//                    debugPrint("fileDownload success")
                    completion(.success(data))
                default:
//                    debugPrint("fileDownload failure")
//                    debugPrint(String(data: data, encoding: .utf8))
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

extension NetworkService.NetworkError: CustomStringConvertible {
    var description: String {
        switch self {
        case .noInternetConnection:
            return "No internet connection at the moment."
        case .responseStatus:
            return "Bad response status."
        case .wrongURL:
            return "Can not use this string to convert to URL."
        case .wrongURLString:
            return "Bad URL."
        }
    }
}
