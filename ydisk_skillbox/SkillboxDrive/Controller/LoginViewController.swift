//
//  LoginViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit
import WebKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel

    private lazy var logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = Constants.Image.sbDrive
        iv.contentMode = .scaleAspectFit
         return iv
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = Constants.Colors.accent1
        button.setTitle(Constants.Text.logIn, for: .normal)
        button.titleLabel?.font = Constants.Fonts.button
        button.addAction(UIAction(handler: { [weak self] _ in
            self?.updateData()
        }), for: .touchUpInside)
        return button
    }()

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(Helper.getToken())")
        view.backgroundColor = .white
        self.navigationItem.hidesBackButton = true
        configureViews()
    }

    private func configureViews() {
        view.addSubview(logoImageView)
        view.addSubview(loginButton)

        logoImageView.snp.makeConstraints { make in
            make.width.equalTo(195)
            make.height.equalTo(168)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(270)
        }
        
        loginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(320)
            make.height.equalTo(50)
            make.top.equalTo(logoImageView.snp.bottom).offset(230)
        }
    }

    private func updateData() {
        
        guard !Helper.getToken().isEmpty else {
            let requestTokenViewController = AuthViewController()
            requestTokenViewController.delegate = self
            navigationController?.pushViewController(requestTokenViewController, animated: true)
            return
        }
        self.dismiss(animated: true)
        PresenterManager.shared.show(vc: .tabBar)
    }
}

extension LoginViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        Helper.setToken(token: token)
        updateData()
    }
}
