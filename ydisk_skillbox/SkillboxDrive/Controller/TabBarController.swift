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
        tabBar.tintColor = Constants.Colors.accent1
        tabBar.unselectedItemTintColor = Constants.Colors.details
        self.selectedIndex = 1
    }
    
//    private func createNavController(for rootViewController: UIViewController, image: UIImage) -> UIViewController {
//        let navController = UINavigationController(rootViewController: rootViewController)
//        navController.tabBarItem.image = image
//        navController .navigationBar.prefersLargeTitles = false
//        return navController
//    }

    // TODO: move create logic to PresenterManager
    func setupViews() {
        viewControllers = [
            presenterManager.createProfileViewController(image: UIImage(named: "tb_person")!),
            presenterManager.createRecentsViewController(image: UIImage(named: "tb_file")!),
            presenterManager.createAllFilesViewController(image: UIImage(named: "tb_archive")!)
        ]
    }
}
