//
//  DetailsPresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 06.12.2022.
//

import UIKit
import PDFKit
import WebKit

protocol DetailsProtocol: AnyObject {
    func presentVC(vc: UIViewController)
    func deleteFileSuccess()
    func loadPDFSuccess(doc: PDFDocument)
    func loadWebView(webView: WKWebView, request: URLRequest)
}

protocol DetailsPresenterProtocol: AnyObject {
    
    init(view: DetailsProtocol)
    var imageCache: NSCache<NSString, UIImage>? { get set }
    
    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func deleteFile(diskItem: YDiskItem)
    func getTitleForItem(name: String, modified: String, fileType: CoreDataManager.elementType) -> UILabel
    
    func loadPDF(pdfView: PDFView, urlString: String)
    func loadWebView(webView: WKWebView, urlString: String)
    
    func shareFile(diskItem: YDiskItem, fileType: CoreDataManager.elementType, pdfView: PDFView)
    func shareLink(diskItem: YDiskItem, fileType: CoreDataManager.elementType, pdfView: PDFView)
    
    func renameFile(diskItem: YDiskItem)
}

class DetailsPresenter: DetailsPresenterProtocol {

    private var view: DetailsProtocol?
    private var networkService: NetworkServiceProtocol!
    private var imageDownloader: ImageDownloader!
    private var networkMonitor: NetworkMonitor?
    private var token = ""
    var imageCache: NSCache<NSString, UIImage>?
    
    required init(view: DetailsProtocol) {
        self.view = view
        self.imageDownloader = ImageDownloader.shared
        self.networkService = NetworkService.shared
        self.networkMonitor = NetworkMonitor.shared
        self.imageCache = imageDownloader.cachedImages
        do { self.token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in RecentImageVC: \(error.localizedDescription)") }
    }

    func downloadImage(urlString: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let image = imageCache?.object(forKey: NSString(string: urlString)) {
            completion(.success(image))
            return
        }
        if !NetworkMonitor.shared.isConnected {
            completion(.failure(NetworkService.NetworkError.noInternetConnection))
            return
        }
        imageDownloader.downloadImage(with: urlString, completion: { result in
                switch result {
                case .success(let image):
                    self.imageCache?.setObject(image, forKey: NSString(string: urlString))
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
        })
    }

    func deleteFile(diskItem: YDiskItem) {
        if !NetworkMonitor.shared.isConnected { return }
        guard let path = diskItem.path else { return }
        NetworkService.shared.fileDelete(path: path) { [weak self] result in
            switch result {
            case .success(_):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    CoreDataManager.shared.context.delete(diskItem)
                    CoreDataManager.shared.saveContext()
                    self.view?.deleteFileSuccess()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

    func getTitleForItem(name: String, modified: String, fileType: CoreDataManager.elementType) -> UILabel {
        let label = UILabel()
        label.font = Constants.Fonts.header2
        label.textColor = Constants.Colors.white
        label.numberOfLines = 2
        label.textAlignment = .center
        
        let firstLine = name
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Fonts.header2!,
            .foregroundColor: fileType == .image ? Constants.Colors.white! : Constants.Colors.black!,
        ]
        let firstAttributedString = NSAttributedString(string: firstLine, attributes: firstAttributes)
        
        let secondLine = modified
        let secondAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Fonts.small!,
            .foregroundColor: Constants.Colors.details!,
        ]
        let secondAttributedString = NSAttributedString(string: secondLine, attributes: secondAttributes)
        
        let finalString = NSMutableAttributedString(attributedString: firstAttributedString)
        finalString.append(NSAttributedString(string: "\n"))
        finalString.append(secondAttributedString)
        label.attributedText = finalString.withLineSpacing(7.0)
        return label
    }
    
    func loadPDF(pdfView: PDFView, urlString: String) {
        if !NetworkMonitor.shared.isConnected { return }
        guard let url = URL(string: urlString) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let doc = PDFDocument(url: url) else { return }
            self?.view?.loadPDFSuccess(doc: doc)
        }
    }
    
    func loadWebView(webView: WKWebView, urlString: String) {
        if !NetworkMonitor.shared.isConnected { return }
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(token)", forHTTPHeaderField: "Authorization")
        DispatchQueue.main.async { [weak self] in
            self?.view?.loadWebView(webView: webView, request: request)
        }
    }

    func shareFile(diskItem: YDiskItem, fileType: CoreDataManager.elementType, pdfView: PDFView) {
        if !NetworkMonitor.shared.isConnected { return }
        if fileType == .image {
            guard let image = ImageDownloader.shared.cachedImages.object(forKey: NSString(string: diskItem.file!)) else { return }
            DispatchQueue.main.async { [weak self] in
                let shareSheetVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self?.view?.presentVC(vc: shareSheetVC)
            }
        }
        else if fileType == .pdf {
            let pdf = pdfView.document?.dataRepresentation()
            DispatchQueue.main.async { [weak self] in
                let shareSheetVC = UIActivityViewController(activityItems: [pdf as Any], applicationActivities: nil)
                self?.view?.presentVC(vc: shareSheetVC)
            }
        }
        else if fileType == .document {
            let path = FileManager.default.temporaryDirectory.appending(path: diskItem.name!)
            networkService.fileDownload(urlString: diskItem.file!) { [weak self] result in
                switch result {
                case .success(let data):
                    guard let file = data else { return }
                    try? file.write(to: path)
                    DispatchQueue.main.async { [weak self] in
                        print("downloaded")
                        let shareSheetVC = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                        self?.view?.presentVC(vc: shareSheetVC)
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
        
    func shareLink(diskItem: YDiskItem, fileType: CoreDataManager.elementType, pdfView: PDFView) {
        if !NetworkMonitor.shared.isConnected { return }
        guard let link = diskItem.file else { return }
        DispatchQueue.main.async { [weak self] in
            let shareSheetVC = UIActivityViewController(activityItems: [link], applicationActivities: nil)
            self?.view?.presentVC(vc: shareSheetVC)
        }
    }
    
    func renameFile(diskItem: YDiskItem) {
        if !NetworkMonitor.shared.isConnected { return }
        let vc = RenameViewController(diskItem: diskItem)
        let presenter = RenamePresenter(view: vc, networkService: NetworkService.shared)
        vc.presenter = presenter
        let nc = UINavigationController(rootViewController: vc)
        self.view?.presentVC(vc: nc)
    }
}
