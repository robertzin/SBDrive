//
//  AuthViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 19.11.2022.
//

import UIKit
import WebKit
import SnapKit

protocol AuthViewControllerDelegate: AnyObject {
    func handleTokenChanged(token: String)
}

class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    var activityIndicator = UIActivityIndicatorView()
    
    private let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        view.addSubview(webView)

        webView.frame = view.frame
        webView.navigationDelegate = self
        webView.addSubview(activityIndicator)
        
        
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(140)
        }
        
        guard let request = request else { return }
        DispatchQueue.main.async { [weak self] in
            self?.webView.load(request)
        }
    }
    
    private var request: URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.urlStringToken) else { return nil }
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "\(Constants.clientId)"),
            URLQueryItem(name: "device_id", value: "\(UIDevice.current.identifierForVendor!)")
        ]
        guard let url = urlComponents.url else { return nil }
        return URLRequest(url: url)
    }
}

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            let targetString = url.absoluteString.replacingOccurrences(of: "#", with: "?")
            guard let components = URLComponents(string: targetString) else { return }
            let token = components.queryItems?.first(where: { $0.name == "access_token" })?.value
            if let token = token {
                navigationController?.popViewController(animated: true)
                delegate?.handleTokenChanged(token: token)
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
}
