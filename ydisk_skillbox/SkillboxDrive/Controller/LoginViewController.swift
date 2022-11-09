//
//  LoginViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

final class LoginViewController: UIViewController {
    private let viewModel: LoginViewModel

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
        
        let dismissButton = UIButton(title: "Dismiss", target: self, selector: #selector(onDismissButton))

      let vStack = UIStackView(arrangedSubviews: [dismissButton])
        addStackView(vStack: vStack)
    }

    @objc
    private func onDismissButton() {
        viewModel.dismiss()
    }
}

extension UIButton {
    convenience init(title: String, target: Any, selector: Selector) {
        self.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setTitle(title, for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        addTarget(target, action: selector, for: .touchUpInside)
    }
}

extension UIViewController {
    func addStackView(vStack: UIStackView) {
        vStack.axis = .vertical
        vStack.spacing = 8.0
        vStack.frame =  CGRect(x: 0, y: 0, width: 300, height: 350)
        vStack.distribution  = .equalCentering
        vStack.alignment = .fill
        vStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(vStack)
        vStack.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        vStack.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
