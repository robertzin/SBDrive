//
//  PublishedMainViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 06.12.2022.
//

import UIKit
import SnapKit

final class PublishedMainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let publishedCellId = "PublishedCell"
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: publishedCellId)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = 55
        return tv
    }()
    
    private var activityIndicator = UIActivityIndicatorView()
    var presenter: PublishedMainPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.getDiskItems(url: Constants.urlStringPublished)
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = Constants.Text.uploadedFiles
        navigationController?.navigationBar.tintColor = Constants.Colors.details
//        setupViewsIfNothingToDisplay()
        setupViewsIfSomethingToDisplay()
    }
    
    private func setupViewsIfSomethingToDisplay() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.subviews.map({ $0.removeFromSuperview() })
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
    
    private func setupViewsIfNothingToDisplay() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.subviews.map({ $0.removeFromSuperview() })
        
        let imageVIew = UIImageView()
        imageVIew.image = UIImage(named: "emptyPublished")
        
        view.addSubview(imageVIew)
        imageVIew.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(159)
            make.height.equalTo(162)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(133)
        }
        
        let textLabel = UILabel()
        view.addSubview(textLabel)
        textLabel.font = Constants.Fonts.header2
        textLabel.text = Constants.Text.noUploadedFiles
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        
        textLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(262)
            make.height.equalTo(38)
            make.top.equalTo(imageVIew.snp.bottom).offset(35)
        }
        
        let button = UIButton()
        view.addSubview(button)
        button.backgroundColor = Constants.Colors.accent2
        button.setTitle(Constants.Text.refresh, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button!
        button.layer.cornerRadius = 10
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
            make.top.equalTo(textLabel.snp.bottom).offset(218)
        }
        button.addTarget(self, action: #selector(refreshData), for: .touchUpInside)
    }
    
    @objc private func refreshData() {
        print("refresh data")
        setupViewsIfSomethingToDisplay()
    }
    
    @objc private func cellButtonTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView as UIView)
        let indexPath: IndexPath! = tableView.indexPathForRow(at: point)
        print("row is = \(indexPath.row) && section is = \(indexPath.section)")
        presenter.alert(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(at: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let diskItem = presenter.dataForDiskItemAt(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: publishedCellId, for: indexPath)
        cell.contentView.layoutIfNeeded()
        
        // cell activity indicator
        let cellActivityIndicator = UIActivityIndicatorView()
        cell.addSubview(cellActivityIndicator)
        cellActivityIndicator.snp.makeConstraints { make in
            make.left.equalTo(cell.contentView.safeAreaLayoutGuide.snp.left).offset(37.5)
            make.centerY.equalToSuperview()
        }
        cellActivityIndicator.startAnimating()
        
        // cell button
        let cellButton = UIButton()
        cellButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        cellButton.tintColor = Constants.Colors.details
        cellButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
        cell.contentView.addSubview(cellButton)
        cell.contentView.layoutIfNeeded()
        cellButton.snp.makeConstraints { make in
            make.width.equalTo(35)
            make.height.equalTo(25)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(15)
        }
        
        // cell content
        var content = cell.defaultContentConfiguration()
        content.image = UIImage()
        content.text = diskItem.name
        content.textProperties.numberOfLines = 1
        content.textProperties.font = Constants.Fonts.mainBody!
        
        let date = diskItem.modified?.toDate() ?? ""
        if diskItem.type != "dir" {
            let size = presenter.mbToKb(size: diskItem.size)
            content.secondaryText = "\(size) \(date)"
        } else { content.secondaryText = date }
        content.secondaryTextProperties.numberOfLines = 1
        content.secondaryTextProperties.font = Constants.Fonts.small!
        content.image = presenter.getImageForCell(diskItem: diskItem)
        cellActivityIndicator.stopAnimating()
        
        content.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 55)
        content.imageProperties.maximumSize = CGSize(width: 55, height: 55)
        cell.contentConfiguration = content
        
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped at \(indexPath.row)")
    }
}

extension PublishedMainViewController: PublishedMainProtocol {
    func success() {
        //        debugPrint("success in Controller")
        CoreDataManager.shared.saveContext()
        try! CoreDataManager.shared.fetchPublishedResultController.performFetch()
        
//        print(CoreDataManager.shared.count())
//        CoreDataManager.shared.printData()
        
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func failure() {
        debugPrint("failure in Controller")
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
    
    func openDiskItemView(vc: UIViewController) {
        
    }
    
    func presentAlert(alert: UIAlertController) {
        navigationController?.present(alert, animated: true)
    }
}
