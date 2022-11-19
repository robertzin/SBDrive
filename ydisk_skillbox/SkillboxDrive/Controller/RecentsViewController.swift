//
//  RecentsViewController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 18.11.2022.
//

import UIKit
import SnapKit

class RecentsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = Constants.Text.recents
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Constants.Fonts.header2!]
    }
}
