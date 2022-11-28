//
//  RecentImageViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 28.11.2022.
//

import UIKit

class RecentImageViewController: UIViewController {
    
    let imageDownloader = ImageDownloader.shared
    var activityIndicator = UIActivityIndicatorView()
    var imageScrollView: ImageScrollView!
    var diskItem: DiskItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureNavigationControllerItems()
        setupViews()
    }
    
    private func getTitleForItem() -> UILabel {
        let label = UILabel()
        label.font = Constants.Fonts.header2
        label.textColor = Constants.Colors.white
        label.numberOfLines = 2
        label.textAlignment = .center
        
        let firstLine = diskItem.name
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Fonts.header2!,
            .foregroundColor: Constants.Colors.white!,
        ]
        let firstAttributedString = NSAttributedString(string: firstLine!, attributes: firstAttributes)
        
        let secondLine = diskItem.modified?.toDate()
        let secondAttributes: [NSAttributedString.Key: Any] = [
            .font: Constants.Fonts.small!,
            .foregroundColor: Constants.Colors.details!,
        ]
        let secondAttributedString = NSAttributedString(string: secondLine!, attributes: secondAttributes)
        
        let finalString = NSMutableAttributedString(attributedString: firstAttributedString)
        finalString.append(NSAttributedString(string: "\n"))
        finalString.append(secondAttributedString)
        label.attributedText = finalString.withLineSpacing(7.0)
        return label
    }
    
    private func configureNavigationControllerItems() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(),for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = Constants.Colors.details
        tabBarController?.tabBar.isHidden = true
        
        let share = UIBarButtonItem(image: UIImage(named: "share"), style: .done, target: self, action: #selector(shareButton))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let delete = UIBarButtonItem(image: UIImage(named: "delete"), style: .done, target: self, action: #selector(deleteButton))
        
        share.tintColor = Constants.Colors.details
        delete.tintColor = Constants.Colors.details
        
        toolbarItems = [share, spacer, delete]
    }
    
    private func makeRightButton() -> UIBarButtonItem {
        let rightButton = UIBarButtonItem(image: UIImage(named: "rename"), style: .plain, target: self, action: #selector(renameButton))
        rightButton.tintColor = Constants.Colors.details
        return rightButton
    }
    
    @objc private func renameButton() {
 
    }
    
    @objc private func shareButton() {
        print("share")
    }
    
    @objc private func deleteButton() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: Constants.Text.deletingImage, attributes: msgAttributes as [NSAttributedString.Key : Any])
        let deleteAction = UIAlertAction(title: Constants.Text.deleteImage , style: .destructive, handler: { [weak self]_ in
            self?.deleteImage {
                DispatchQueue.main.async {
                    print("image deleted")
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)
        
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    private func deleteImage(completion: @escaping () -> Void) {
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/resources"), let path = diskItem.path else { return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "path", value: path),
            URLQueryItem(name: "permanently", value: "true")
        ]
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.setValue("OAuth \(Helper.getToken())", forHTTPHeaderField: "Authorization")
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error )in
            if let response = response as? HTTPURLResponse {
                print("request")
                switch response.statusCode {
                case 200..<300:
                    print("success")
                default:
                    print("failure")
                }
                completion()
            }
        }.resume()
    }
    
    private func setupViews() {
        configureNavigationControllerItems()
        
        self.view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.height.width.equalTo(140)
        }
        activityIndicator.startAnimating()
        
        let iv = ImageScrollView(frame: view.unsafelyUnwrapped.bounds)
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFit
        ImageDownloader.shared.downloadImage(with: diskItem.file, completion: { [weak self] result in
            switch result {
            case .success(let image):
                iv.set(image: image)
                self?.activityIndicator.stopAnimating()
                self?.navigationItem.titleView = self?.getTitleForItem()
                self?.navigationItem.rightBarButtonItem = self?.makeRightButton()
                self?.navigationController?.toolbar.isHidden = false
                self?.navigationController?.setToolbarHidden(false, animated: false)
                self?.view.addSubview(iv)
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        }, placeholderImage: UIImage(named: "tb_person"))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false
        navigationController!.view.backgroundColor = .white
        navigationController?.toolbar.isHidden = true
        navigationController?.setToolbarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
    }
}

extension NSAttributedString {
    func withLineSpacing(_ spacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(attributedString: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = spacing
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: string.count))
        return NSAttributedString(attributedString: attributedString)
    }
}
