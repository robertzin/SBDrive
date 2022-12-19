//
//  RenameViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 30.11.2022.
//

import UIKit

class RenameViewController: UITableViewController, UITextFieldDelegate {
    
    private var diskItem: YDiskItem
    private var newTitle = ""
    private var fileFormat: String?
    
    var presenter: RenamePresenterProtocol!
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = Constants.Fonts.mainBody
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 0.25
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.shadowOpacity = 1.0
        textField.layer.shadowRadius = 2.0
        textField.layer.shadowOffset = CGSize(width: 0, height: 1)
        textField.layer.shadowColor = Constants.Colors.details?.cgColor
        textField.clearButtonMode = .whileEditing
        textField.leftViewMode = UITextField.ViewMode.always
        textField.delegate = self
        return textField
    }()
    
    init(diskItem: YDiskItem) {
        self.diskItem = diskItem
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.becomeFirstResponder()
        title = Constants.Text.rename
        presenter.getToken()
        setupViews()
    }
    
    private func getIconForTextField() {
        let leftPading = 11
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 40 + leftPading + 10, height: 40))
        let iv = UIImageView(frame: CGRect(x: leftPading, y: 0, width: 40, height: 40))
        iv.contentMode = .scaleAspectFit
        iconContainer.addSubview(iv)
        
        guard let urlString = diskItem.preview else { return }
        presenter.downloadImage(urlString: urlString, completion: { [weak self ]result in
            switch result {
            case .success(let image):
                let image = image
                iv.image = image;
                self?.textField.leftView = iconContainer;
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    private func setupViews() {
        view.addSubview(textField)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .done, target: self, action: #selector(backButton))
        navigationItem.leftBarButtonItem?.tintColor = Constants.Colors.details
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: Constants.Text.done, style: .done, target: self, action: #selector(doneButton))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([NSAttributedString.Key.font : Constants.Fonts.small!], for: .normal)
        
        let idx = diskItem.name?.lastIndex(of: ".")
        textField.text = String(diskItem.name![..<idx!])
        self.fileFormat = String(diskItem.name![idx!...])
        
        getIconForTextField()
        textField.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
    }
    
    @objc private func backButton() {
        self.dismiss(animated: true)
    }
    
    @objc private func doneButton() {
        view.endEditing(true)
        self.newTitle.append(self.fileFormat!)
        
        if self.newTitle == diskItem.name {
            self.dismiss(animated: true)
            return
        }
        
        presenter.renameFile(diskItem: self.diskItem, newTitle: newTitle)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.newTitle = textField.text ?? "noname"
    }
}

extension RenameViewController: RenameProtocol {
    func dismissVC() {
        self.dismiss(animated: true)
    }
}
