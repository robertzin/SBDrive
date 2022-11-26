//
//  RecentsViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 18.11.2022.
//

import UIKit
import SnapKit

class RecentsViewController: UITableViewController {

    private let cellId = "DiskResponseCellId"
    private let urlString = "https://cloud-api.yandex.net/v1/disk/resources/last-uploaded?limit=100"
    private var activityIndicator = UIActivityIndicatorView()
    var diskItems = [DiskItem]()
    
    var presenter: RecentsMainPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.getDiskItems(url: urlString)
        setupViews()
        configureRefreshControl()
    }
    
    private func setupViews() {
        view.addSubview(activityIndicator)
        view.backgroundColor = .white
        navigationItem.title = Constants.Text.recents
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Constants.Fonts.header2!]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 55

        activityIndicator.startAnimating()
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(140)
        }
    }
    
    private func configureRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self,
                                       action: #selector(handleRefreshControl),
                                       for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
//        presenter.getDiskItems(url: urlString)
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected at \(indexPath.row)")
//        presenter.didSelectDiskItemAt(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let diskItem = presenter.dataForDiskItemAt(indexPath)
        let imageUrl = diskItem.preview ?? "https://bilgi-sayar.net/wp-content/uploads/2012/01/na.jpg"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        var content = cell.defaultContentConfiguration()

        content.text = diskItem.name
        content.textProperties.numberOfLines = 1
        content.textProperties.font = Constants.Fonts.mainBody!
        
        let size = presenter.mbToKb(size: diskItem.size!)
        content.secondaryText = "\(size) \((diskItem.modified?.toDate())!)"
        content.secondaryTextProperties.numberOfLines = 1
        content.secondaryTextProperties.font = Constants.Fonts.small!
        
        content.image = self.presenter.imageCache?.object(forKey: NSString(string: imageUrl))
        content.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 55)
        content.imageProperties.maximumSize = CGSize(width: 55, height: 55)

        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(at: section)
    }
}

extension RecentsViewController: RecentsMainProtocol {
    func success() {
//        debugPrint("success in Controller")
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }

    func failure() {
//        debugPrint("failure in Controller")
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }

    func imageDownloadingSuccess() {
//        debugPrint("downloading image success in Controller")
        tableView.reloadData()
    }

    func imageDownloadingFailure() {
        debugPrint("downloading image failure in Controller")
    }

    func openDiskItemView(diskItem: DiskItem) {
        print("open details:")
//        navigationController?.pushViewController(<#T##viewController: UIViewController##UIViewController#>, animated: <#T##Bool#>)
    }
}
