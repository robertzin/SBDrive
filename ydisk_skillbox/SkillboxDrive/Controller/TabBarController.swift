//
//  TabBarController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 11.11.2022.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let viewModel: TabBarViewModel
    private let presenterManager = PresenterManager.shared
    
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        delegate = self
        tabBar.tintColor = Constants.Colors.accent1
        tabBar.unselectedItemTintColor = Constants.Colors.details
        self.selectedIndex = 1
    }

    func setupViews() {
        viewControllers = [
            presenterManager.createProfileViewController(image: UIImage(named: "tb_person")!),
            presenterManager.createRecentsViewController(image: UIImage(named: "tb_file")!),
            presenterManager.createAllFilesViewController(image: UIImage(named: "tb_archive")!)
        ]
    }
}

extension TabBarController: UITabBarControllerDelegate  {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
          return false
        }

        if fromView != toView {
          UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        return true
    }
}
