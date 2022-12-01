//
//  ProfileViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 18.11.2022.
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    
    private var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do { token = try KeyChain.shared.getToken() }
        catch { print("error while getting token in ProfileVC: \(error.localizedDescription)") }
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
                self.logOut()
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
    
    private func logOut() {
        do { try KeyChain.shared.deleteToken() }
        catch { print("error while deleting token: \(error.localizedDescription)") }
        CoreDataManager.shared.deleteAllEntities()
        
        var request = URLRequest(url: URL(string: "https://oauth.yandex.ru/revoke_token")!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let dataString = "access_token=\(token)&client_id=\(Constants.clientId)&client_secret=\(Constants.clientSecret)"
        let data : Data = dataString.data(using: .utf8)!
        request.httpBody = data
        request.setValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                switch response.statusCode {
                case 200..<300:
                    print("Success")
                default:
                    print("Status: \(response.statusCode)")
                }
            }
        }.resume()
    }
}

extension String {
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func toDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm"
        
        let parsedDate = dateFormatter.date(from: self)!
        return dateFormatterPrint.string(from: parsedDate)
    }
}
