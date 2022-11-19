//
//  LoginViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

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
            // TODO: make helper function for login and logout?
            if let window = self?.view.window {
                self?.dismiss(animated: true)
                let r = DefaultRouter(rootTransition: EmptyTransition())
                let vm = TabBarViewModel(router: r)
                window.rootViewController = TabBarController(viewModel: vm)
                UIView.transition(with: window,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: nil)
            }
        }), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
       let sv = UIStackView()
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = 35
        return sv
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
        view.backgroundColor = .white
        configureViews()
    }

    private func configureViews() {
        view.addSubview(logoImageView)
        view.addSubview(stackView)

        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(55)
            make.width.height.equalTo(150)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().inset(55)
            make.height.equalTo(view.frame.size.height / 4)
            make.top.equalTo(logoImageView.snp.bottom).offset(55)
        }
        
        stackView.addArrangedSubview(setupTextField(placeholder: "Email"))
        stackView.addArrangedSubview(setupTextField(placeholder: "Password"))
        stackView.addArrangedSubview(loginButton)
    }
    
    private func setupTextField(placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.delegate = self
        textField.placeholder = placeholder
        textField.borderStyle = .bezel
        textField.backgroundColor = .white
        textField.textColor = Constants.Colors.black
        textField.font = Constants.Fonts.mainBody
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }
}

extension LoginViewController: UITextFieldDelegate {
    
}
