//
//  ProfileViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 18.11.2022.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.Text.profile
        navigationItem.rightBarButtonItem = makeRightButton()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Constants.Fonts.header2!]
        view.backgroundColor = .white
    }
    
    private func makeRightButton() -> UIBarButtonItem {
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "ellipsis"), style: .plain, target: self, action: #selector(buttonPressed))
        rightButton.tintColor = Constants.Colors.details
        return rightButton
    }
    
    @objc private func buttonPressed() {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let msgAttributes = [NSAttributedString.Key.font: Constants.Fonts.small!, NSAttributedString.Key.foregroundColor: Constants.Colors.details]
        let msgString = NSAttributedString(string: Constants.Text.profile, attributes: msgAttributes as [NSAttributedString.Key : Any])
        let quitAction = UIAlertAction(title: Constants.Text.logOut, style: .destructive, handler: {_ in
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            
            let attributedStringTitle = NSAttributedString(string: Constants.Text.quit, attributes: [NSAttributedString.Key.font: Constants.Fonts.header2!])
            let attributedStringMessage = NSAttributedString(string: Constants.Text.wantLogOut, attributes: [NSAttributedString.Key.font: Constants.Fonts.mainBody!])
            
            let yesAction = UIAlertAction(title: Constants.Text.yes, style: .default) { action in
                Helper.eraseToken()
                self.dismiss(animated: true)
                PresenterManager.shared.show(vc: .login)
            }
            alert.setValue(attributedStringTitle, forKey: "attributedTitle")
            alert.setValue(attributedStringMessage, forKey: "attributedMessage")
            alert.addAction(yesAction)
            alert.addAction(UIAlertAction(title: Constants.Text.no, style: .destructive))
            
            self.navigationController?.present(alert, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel, handler: nil)
        
        alert.setValue(msgString, forKey: "attributedMessage")
        alert.addAction(quitAction)
        alert.addAction(cancelAction)

        self.navigationController?.present(alert, animated: true, completion: nil)
    }
}
