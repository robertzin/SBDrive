//
//  PublishedMainViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 06.12.2022.
//

import UIKit
import SnapKit

class PublishedMainViewController: UIViewController {
    
    private let cellId = "DiskResponsePublishedCellId"
    private var activityIndicator = UIActivityIndicatorView()
    var presenter: PublishedMainPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        view.backgroundColor = .white
        navigationItem.title = Constants.Text.uploadedFiles
        navigationController?.navigationBar.tintColor = Constants.Colors.details
    }
    
    private func setupViews() {
        setupViewsIfNothingToDisplay()
        setupViewsIfSomethingToDisplay()
    }
    
    private func setupViewsIfSomethingToDisplay() {
        view.subviews.forEach({ $0.removeFromSuperview() })
        view.subviews.map({ $0.removeFromSuperview() })
        
        let label = UILabel()
        label.text = "Hello, mutherf*cker!"
        label.textAlignment = .center
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalToSuperview().inset(55)
            make.height.equalTo(65)
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
}

extension PublishedMainViewController: PublishedMainProtocol {
    func success() {
        
    }
    
    func failure() {
        
    }
    
    func imageDownloadingSuccess() {
        
    }
    
    func imageDownloadingFailure() {
        
    }
    
    func openDiskItemView(vc: UIViewController) {
        
    }
}
