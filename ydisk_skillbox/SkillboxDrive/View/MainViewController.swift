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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.getDiskItems(url: requestURLstring!)
        setupViews()
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
    
    private func setupViewsIfSomethingToDisplay() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.subviews.map({ $0.removeFromSuperview() })
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        tableView.addSubview(refreshControl)
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
        presenter.getDiskItems(url: requestURLstring!)
    }
    
    @objc func handleRefreshControl() {
        presenter.getDiskItems(url: requestURLstring!)
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
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
        hidesBottomBarWhenPushed = true
        presenter.didSelectDiskItemAt(indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(at: section)
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        self.tableView.tableFooterView = createFooterSpinner()
//        presenter.rowToPaginate(indexPath)
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if header == Constants.Text.recents { return }
        let position = scrollView.contentOffset.y
        if position > tableView.contentSize.height - scrollView.frame.size.height {
            self.tableView.tableFooterView = createFooterSpinner()
            presenter.performPaginate(url: requestURLstring!)
        }
    }
}

extension MainViewController: MainProtocol {
    func success() {
//        debugPrint("success in Controller")
        DispatchQueue.main.async { self.tableView.tableFooterView = nil }
        presenter.coreDataManager.saveContext()
        try! presenter.fetchResultController.performFetch()
//        print(presenter.coreDataManager.count())
//        presenter.coreDataManager.printData()
        
        if presenter.fetchResultController.fetchedObjects!.count > 0 {
            self.setupViewsIfSomethingToDisplay()
        } else {
            setupViewsIfNothingToDisplay()
        }
        activityIndicator.stopAnimating()
        tableView.reloadData()
    }
    
    func failure() {
        debugPrint("failure in Controller")
        if self.tableView.tableFooterView != nil {
            DispatchQueue.main.async { self.tableView.tableFooterView = nil }
        }
        if activityIndicator.isAnimating {
            activityIndicator.stopAnimating()
        }
//        tableView.reloadData()
    }
    
    func imageDownloadingSuccess() {
//        debugPrint("downloading image success in Controller")
        tableView.reloadData()
    }
    
    func imageDownloadingFailure() {
        debugPrint("downloading image failure in Controller")
    }
    
    func openDiskItemView(vc: UIViewController) {
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
                cell.contentView.layoutIfNeeded()
                
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
                
                content.imageProperties.reservedLayoutSize = CGSize(width: 55, height: 55)
                content.imageProperties.maximumSize = CGSize(width: 55, height: 55)
                cell.contentConfiguration = content
                
                cell.contentView.setNeedsLayout()
                cell.contentView.layoutIfNeeded()
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
