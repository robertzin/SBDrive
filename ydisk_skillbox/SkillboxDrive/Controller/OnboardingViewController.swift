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
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == OnboardingSlide.slides.count - 1 {
                nextButton.setTitle(Constants.Text.getStarted, for: .normal)
            } else {
                nextButton.setTitle(Constants.Text.next, for: .normal)
            }
        }
    }

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = layout
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = Constants.Colors.accent1
        pageControl.pageIndicatorTintColor = Constants.Colors.onboardingDot
        pageControl.numberOfPages = 3
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
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: "cellId")

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
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(65)
            make.width.equalToSuperview()
            make.height.equalTo(500)
        }
        
        pageControl.frame = CGRect(x: 10, y: view.frame.size.height - 100, width: view.frame.size.width - 50, height: 120)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(100)
        }
        
        nextButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
            make.top.equalTo(pageControl.snp.bottom).offset(35)
        }
        
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    @objc func nextButtonTapped(sender: UIButton!) {
        if currentPage == OnboardingSlide.slides.count - 1 {
            debugPrint("Login")
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! OnboardingCollectionViewCell
        cell.set(to: OnboardingSlide.slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return OnboardingSlide.slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width)
    }
}
