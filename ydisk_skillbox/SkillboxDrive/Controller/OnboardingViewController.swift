//
//  OnboardingViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit
import SnapKit

final class OnboardingViewController: UIViewController {
    
    private let viewModel: OnboardingViewModel
    
    private lazy var collectionView: UICollectionView = {
       let collectionView = UICollectionView()
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
//        pageControl.pageIndicatorTintColor = Constants.Colors.accent1
        pageControl.numberOfPages = 3
        pageControl.backgroundColor = .red
        return pageControl
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = Constants.Colors.accent1
        button.setTitle(Constants.Text.next, for: .normal)
        button.tintColor = Constants.Colors.white
        button.titleLabel?.font = Constants.Fonts.button
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Constants.Colors.white
        configureViews()
    }
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        pageControl.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.width.equalTo(45)
            make.height.equalTo(8.41)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
            make.top.equalTo(pageControl.snp.bottom).offset(41.47)
        }
    }
}
