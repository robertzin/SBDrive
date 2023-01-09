//
//  DetailsViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 28.11.2022.
//

import UIKit
import PDFKit
import WebKit

final class DetailsViewController: UIViewController, PDFViewDelegate, WKUIDelegate {
    
    var presenter: DetailsPresenterProtocol!
    weak var imageScrollView: ImageScrollView!
    
    private var activityIndicator = UIActivityIndicatorView()
    private var fileType: CoreDataManager.elementType
    private lazy var webView: WKWebView = {
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true
        
        webView.frame = view.safeAreaLayoutGuide.layoutFrame
        webView.addSubview(activityIndicator)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        return webView
    }()
    private var pdfView = PDFView()
    private var diskItem: YDiskItem
    
    init(diskItem: YDiskItem, type: CoreDataManager.elementType) {
        self.diskItem = diskItem
        self.fileType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(performAfter), name: NSNotification.Name(rawValue:  "PeformAfterPresenting"), object: nil)
        presenter.getToken()
        setupViews()
    }

    @objc func performAfter(_ notification: Notification) {
        let name = notification.userInfo?["name"] as! String
        let modified = notification.userInfo?["modified"] as! String
        self.navigationItem.titleView = presenter.getTitleForItem(name: name, modified: modified, fileType: self.fileType)
    }

    private func configureNavigationControllerItems() {
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
        self.presenter.renameFile(diskItem: diskItem)
    }

    @objc private func shareButton() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: Constants.Text.share, attributes: msgAttributes as [NSAttributedString.Key : Any])

        let fileAction = UIAlertAction(title: Constants.Text.sendFile , style: .default, handler: { [weak self]_ in
            guard let self = self else { return }
            self.presenter.shareFile(diskItem: self.diskItem, fileType: self.fileType, pdfView: self.pdfView)
        })
        let linkAction = UIAlertAction(title: Constants.Text.sendLink , style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            self.presenter.shareLink(diskItem: self.diskItem, fileType: self.fileType, pdfView: self.pdfView)
        })
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)

        alert.view.tintColor = .black
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(fileAction)
        alert.addAction(linkAction)
        alert.addAction(cancelAction)
        self.navigationController?.present(alert, animated: true, completion: nil)
    }

    @objc private func deleteButton() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: Constants.Text.fileWillBeDeleted, attributes: msgAttributes as [NSAttributedString.Key : Any])
        let deleteAction = UIAlertAction(title: Constants.Text.delete , style: .destructive, handler: { [weak self]_ in
            self?.presenter.deleteFile(diskItem: self!.diskItem)
        })
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)

        alert.view.tintColor = .black
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        self.navigationController?.present(alert, animated: true, completion: nil)
    }

    private func proceedWithImage() {
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(),for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        activityIndicator.startAnimating()

        let iv = ImageScrollView(frame: view.unsafelyUnwrapped.bounds)
        iv.backgroundColor = .black
        iv.contentMode = .scaleAspectFit
        guard let urlString = diskItem.file else { return }
        presenter.downloadImage(urlString: urlString, completion: { [weak self] result in
            switch result {
            case .success(let image):
                iv.set(image: image)
                self?.activityIndicator.stopAnimating()
                if let name = self?.diskItem.name, let modified = self?.diskItem.modified?.toDate() {
                    guard let type = self?.fileType else { return }
                    self?.navigationItem.titleView = self?.presenter.getTitleForItem(name: name, modified: modified, fileType: type)
                }
                self?.navigationItem.rightBarButtonItem = self?.makeRightButton()
                self?.navigationController?.toolbar.isHidden = false
                self?.navigationController?.setToolbarHidden(false, animated: false)
                self?.view.addSubview(iv)
            case .failure(let error):
                debugPrint(error.localizedDescription)
            }
        })
    }

    private func proceedWithPDF() {
        view.addSubview(pdfView)
        pdfView.addSubview(activityIndicator)
        pdfView.frame = view.frame
        activityIndicator.startAnimating()

        navigationItem.rightBarButtonItem = self.makeRightButton()
        navigationController?.toolbar.isHidden = false
        navigationController?.toolbar.backgroundColor = .white
        navigationController?.setToolbarHidden(false, animated: false)
        //
        //        pdfView.snp.makeConstraints { make in
        //            make.centerX.equalToSuperview()
        //            make.top.equalToSuperview().offset(105)
        //            make.bottom.equalToSuperview().inset(145)
        //            make.width.equalToSuperview()
        //        }
        //

        guard let urlString = diskItem.file else { return }
        self.presenter.loadPDF(pdfView: self.pdfView, urlString: urlString)
    }

    private func proceedWithDocument() {
        view.addSubview(webView)
        guard let urlString = diskItem.file else { return }
        presenter.loadWebView(webView: webView, urlString: urlString)
    }

    private func setupViews() {
        configureNavigationControllerItems()
        self.view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.height.width.equalTo(140)
        }

        switch self.fileType {
        case .image:
            proceedWithImage()
        case .pdf:
            proceedWithPDF()
        case .document:
            proceedWithDocument()
        default:
            print("some error")
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isTranslucent = false
        navigationController!.view.backgroundColor = .white
        navigationController?.toolbar.isHidden = true
        navigationController?.toolbar.backgroundColor = .clear
        navigationController?.setToolbarHidden(true, animated: false)
        tabBarController?.tabBar.layer.zPosition = 0
        tabBarController?.tabBar.isHidden = false

        if self.fileType == .pdf {
            pdfView.removeFromSuperview()
            } else if self.fileType == .document {
                webView.removeFromSuperview()
        }
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

extension DetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
        navigationItem.rightBarButtonItem = self.makeRightButton()
        navigationController?.toolbar.isHidden = false
        navigationController?.toolbar.backgroundColor = .white
        navigationController?.setToolbarHidden(false, animated: false)
        if let name = self.diskItem.name, let modified = self.diskItem.modified?.toDate() {
            self.navigationItem.titleView = presenter.getTitleForItem(name: name, modified: modified, fileType: self.fileType)
        }
    }
}

extension DetailsViewController: DetailsProtocol {
    func presentVC(vc: UIViewController) {
        self.present(vc, animated: true)
    }

    func deleteFileSuccess() {
        self.navigationController?.popViewController(animated: true)
    }

    func loadPDFSuccess(doc: PDFDocument) {
        self.activityIndicator.stopAnimating()
        self.pdfView.document = doc
        self.pdfView.autoScales = true
        self.pdfView.maxScaleFactor = 4.0
        self.pdfView.minScaleFactor = self.pdfView.scaleFactorForSizeToFit
        self.activityIndicator.stopAnimating()
        if let name = self.diskItem.name, let modified = self.diskItem.modified?.toDate() {

            self.navigationItem.titleView = self.presenter.getTitleForItem(name: name, modified: modified, fileType: self.fileType)
        }
    }

    func loadWebView(webView: WKWebView, request: URLRequest) {
        webView.load(request)
    }
}
