//
//  TabBarController.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 11.11.2022.
//

import UIKit

class TabBarController: UITabBarController {
    
    private let viewModel: TabBarViewModel
    
    init(viewModel: TabBarViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("token: " + Helper.getToken())
        view.backgroundColor = .white
        tabBar.tintColor = Constants.Colors.accent1
        tabBar.unselectedItemTintColor = Constants.Colors.details
        setupViews()
    }
    
    private func createNavController(for rootViewController: UIViewController, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController .navigationBar.prefersLargeTitles = false
        return navController
    }

    func setupViews() {
        viewControllers = [
            createNavController(for: ProfileViewController(), image: UIImage(named: "tb_person")!),
            createNavController(for: RecentsViewController(), image: UIImage(named: "tb_file")!),
            createNavController(for: AllFilesViewController(), image: UIImage(named: "tb_archive")!)
        ]
    }
}
