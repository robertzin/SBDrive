//
//  MainViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.01.2023.
//

import UIKit
import SnapKit
import CoreData

final class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    private let cellId = "cellId"
    private lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.rowHeight = 55
        return tv
    }()
    
    private lazy var noDataImageView: UIImageView = {
        let imageVIew = UIImageView()
        imageVIew.image = UIImage(named: "emptyPublished")
        return imageVIew
    }()
    
    private lazy var noDataInDirectoryLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = Constants.Fonts.header2
        textLabel.text = Constants.Text.emptyDir
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        return textLabel
    }()
    
    private lazy var noDataLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = Constants.Fonts.header2
        textLabel.text = Constants.Text.noUploadedFiles
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 2
        return textLabel
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Constants.Colors.accent2
        button.setTitle(Constants.Text.refresh, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button!
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(refreshDataOnButtonTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var noConnectionLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.Text.noInternet
        label.font = Constants.Fonts.small
        label.textColor = .white
        label.textAlignment = .center
        label.center = view.center
        return label
    }()
    
    private lazy var noConnectionView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = Constants.Colors.noConnection
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(handleRefreshControl),
                                 for: .valueChanged)
        return refreshControl
    }()
    
    private var header: String?
    private var requestURLstring: String?
    private var activityIndicator = UIActivityIndicatorView()
    private var footerActivityIndicator = UIActivityIndicatorView()
    var presenter: MainPresenterProtocol!
    
    init(requestURLstring: String?, header: String) {
        super.init(nibName: nil, bundle: nil)
        self.header = header
        self.requestURLstring = requestURLstring
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        hidesBottomBarWhenPushed = false
        navigationController?.navigationBar.isTranslucent = false
        navigationController!.view.backgroundColor = .white
        navigationController?.toolbar.isHidden = true
        navigationController?.toolbar.backgroundColor = .clear
        navigationController?.setToolbarHidden(true, animated: false)
        tabBarController?.tabBar.layer.zPosition = 0
        tabBarController?.tabBar.isHidden = false
//        tableView.contentInset = UIEdgeInsets.init(top: 0, left: 0, bottom: CGRectGetHeight((self.tabBarController?.tabBar.frame)!), right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleConnectionLabel(notification: Notification(name: NSNotification.Name(rawValue:  "connectivityStatusChanged")))
        NotificationCenter.default.addObserver(self, selector: #selector(handleConnectionLabel(notification:)), name: NSNotification.Name(rawValue:  "connectivityStatusChanged"), object: nil)
        setupViews()
        presenter.getDiskItems(url: requestURLstring!)
    }
    
    private func setupViews() {
        view.addSubview(activityIndicator)
        view.backgroundColor = .white
        navigationItem.title = self.header
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Constants.Fonts.header2!]
        navigationController?.navigationBar.tintColor = Constants.Colors.details
        presenter.fetchResultController.delegate = self
        
        activityIndicator.startAnimating()
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.height.width.equalTo(140)
        }
    }
    
    @objc func handleConnectionLabel(notification: Notification) {
            if NetworkMonitor.shared.isConnected {
//                debugPrint("Connected")
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1, delay: 0.15) {
                        self.viewDissapear(view: self.noConnectionView)
                    } completion: { _ in
                        self.noConnectionLabel.removeFromSuperview()
                        self.noConnectionView.removeFromSuperview()
                    }
                }
            } else {
//                debugPrint("Not connected")
                DispatchQueue.main.async {
                    self.view.addSubview(self.noConnectionView)
                    self.noConnectionView.snp.makeConstraints { make in
                        make.width.equalToSuperview()
                        make.height.equalTo(40)
                        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                    }
                    
                    self.noConnectionView.addSubview(self.noConnectionLabel)
                    self.noConnectionLabel.snp.makeConstraints { make in
                        make.width.equalTo(self.noConnectionView)
                        make.height.equalTo(self.noConnectionView)
                        make.centerX.equalTo(self.noConnectionView.snp.centerX)
                    }
                    UIView.animate(withDuration: 1, delay: 0.15) {
                        self.viewAppear(view: self.noConnectionView)
                    }
                }
            }
        }
    
    private func viewDissapear(view: UIView) { view.alpha = 0 }
    
    private func viewAppear(view: UIView) { view.alpha = 1 }
    
    private func setupViewsIfSomethingToDisplay() {
        noDataInDirectoryLabel.removeFromSuperview()
        UIView.animate(withDuration: 0.35, delay: 0.2) {
            self.viewDissapear(view: self.refreshButton)
        } completion: { _ in
            self.refreshButton.removeFromSuperview()
        }

        UIView.animate(withDuration: 0.35, delay: 0.2) {
            self.viewDissapear(view: self.noDataLabel)
        } completion: { _ in
            self.noDataLabel.removeFromSuperview()
        }

        UIView.animate(withDuration: 0.35, delay: 0.2) {
            self.viewDissapear(view: self.noDataImageView)
        } completion: { _ in
            self.noDataImageView.removeFromSuperview()
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        tableView.addSubview(refreshControl)
    }
    
    private func setupViewsIfNothingToDisplay() {
        self.tableView.removeFromSuperview()
                
        if header != Constants.Text.allFiles && header != Constants.Text.recents && header != Constants.Text.uploadedFiles {
            view.addSubview(noDataInDirectoryLabel)
            noDataInDirectoryLabel.snp.makeConstraints { make in
                make.centerX.centerY.equalToSuperview()
                make.width.equalTo(270)
                make.height.equalTo(40)
            }
            return
        }
        
        view.addSubview(noDataImageView)
        noDataImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(159)
            make.height.equalTo(162)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(133)
        }
        
        view.addSubview(noDataLabel)
        noDataLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(262)
            make.height.equalTo(38)
            make.top.equalTo(noDataImageView.snp.bottom).offset(35)
        }
        
        view.addSubview(refreshButton)
        refreshButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
            make.top.equalTo(noDataLabel.snp.bottom).offset(218)
        }
    }

    @objc private func refreshDataOnButtonTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.refreshButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.refreshButton.transform = CGAffineTransform.identity
            }
        })
        activityIndicator.startAnimating()
        presenter.getDiskItems(url: requestURLstring!)
    }
    
    @objc func handleRefreshControl() {
        presenter.getDiskItems(url: requestURLstring!)
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    @objc private func cellButtonTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView as UIView)
        let indexPath: IndexPath! = tableView.indexPathForRow(at: point)
//        debugPrint("row is = \(indexPath.row) && section is = \(indexPath.section)")
        presenter.alert(indexPath: indexPath)
    }
    
    func createFooterSpinner() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        footerActivityIndicator.center = footerView.center
        footerView.addSubview(footerActivityIndicator)
        footerActivityIndicator.startAnimating()
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let diskItem = presenter.dataForDiskItemAt(indexPath)
        let cellActivityIndicator = UIActivityIndicatorView()
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        // cell activity indicator
        cell.contentView.addSubview(cellActivityIndicator)
        cellActivityIndicator.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(37.5)
            make.centerY.equalToSuperview()
        }
        cellActivityIndicator.hidesWhenStopped = true
        cellActivityIndicator.startAnimating()
        
        // cell button
        if header != Constants.Text.recents {
            let cellButton = UIButton()
            cellButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            cellButton.tintColor = Constants.Colors.details
            cellButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
            cell.contentView.addSubview(cellButton)
            cellButton.snp.makeConstraints { make in
                make.width.equalTo(35)
                make.height.equalTo(25)
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().inset(15)
            }
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
        
        content.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 55)
        content.imageProperties.maximumSize = CGSize(width: 55, height: 55)
        cell.contentConfiguration = content
        cellActivityIndicator.stopAnimating()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectDiskItemAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(at: section)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - scrollView.frame.size.height + 250 {
            self.tableView.tableFooterView = createFooterSpinner()
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(750)) { [weak self] in
                self?.presenter.performPaginate(url: (self?.requestURLstring)!)
            }
        }
    }
}

extension MainViewController: MainProtocol {
    func success() {
        if self.tableView.tableFooterView != nil {
            DispatchQueue.main.async { [weak self] in self?.tableView.tableFooterView = nil }
        }
        presenter.coreDataManager.saveContext()
        try! presenter.fetchResultController.performFetch()
        if presenter.fetchResultController.fetchedObjects!.count > 0 {
            self.setupViewsIfSomethingToDisplay()
        } else {
            setupViewsIfNothingToDisplay()
        }
        handleConnectionLabel(notification: Notification(name: NSNotification.Name(rawValue:  "connectivityStatusChanged")))
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func failure() {
//        debugPrint("failure in Controller")
        if self.tableView.tableFooterView != nil {
            DispatchQueue.main.async { self.tableView.tableFooterView = nil }
        }
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
        handleConnectionLabel(notification: Notification(name: NSNotification.Name(rawValue:  "connectivityStatusChanged")))
    }
    
    func imageDownloadingSuccess() {
//        debugPrint("downloading image success in Controller")
        tableView.reloadData()
    }
    
    func imageDownloadingFailure() {
        debugPrint("downloading image failure in Controller")
    }
    
    func openDiskItemView(vc: UIViewController, isDirectory: Bool = false) {
        if isDirectory == false {
            hidesBottomBarWhenPushed = true
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func presentAlert(alert: UIAlertController) {
        navigationController?.present(alert, animated: true)
    }
}

extension MainViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
//            print("insert")
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
//            print("update")
            if let indexPath = indexPath {
                let diskItem = presenter.dataForDiskItemAt(indexPath)
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
                
                // cell button
                if header != Constants.coreDataRecents {
                    let cellButton = UIButton()
                    cellButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
                    cellButton.tintColor = Constants.Colors.details
                    cellButton.addTarget(self, action: #selector(cellButtonTapped), for: .touchUpInside)
                    cell.contentView.addSubview(cellButton)
                    cellButton.snp.makeConstraints { make in
                        make.width.equalTo(35)
                        make.height.equalTo(25)
                        make.centerY.equalToSuperview()
                        make.right.equalToSuperview().inset(15)
                    }
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
                
                content.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 55)
                content.imageProperties.maximumSize = CGSize(width: 55, height: 55)
                cell.contentConfiguration = content
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        @unknown default:
            fatalError()
        }
    }
}
