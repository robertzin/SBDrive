//
//  LoadingViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

final class LoadingViewController: UIViewController {
    private let viewModel: LoadingViewModel
    
    init(viewModel: LoadingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isLoggedIn: Bool = true
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "sbDrive") ?? UIImage()
        return imageView
    }()
    
    override func viewDidLoad() {
//        print("token: " + Helper.getToken())
        view.backgroundColor = .white
        super.viewDidLoad()
        configureViews()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.loadingDelay) {
            self.showInitialView()
        }
    }
    
    private func configureViews() {
        view.addSubview(imageView)
        view.backgroundColor = .white
        imageView.snp.makeConstraints { make in
            make.width.equalTo(195)
            make.height.equalTo(168)
            make.centerX.centerY.equalToSuperview()
        }
    }

    private func showInitialView() {
        self.dismiss(animated: true)
        if !Helper.getToken().isEmpty {
            PresenterManager.shared.show(vc: .tabBar)
        } else {
            viewModel.onboarding()
        }
    }
}

