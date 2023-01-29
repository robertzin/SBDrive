//
//  PresenterManager.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 21.11.2022.
//

import UIKit

class PresenterManager {
    
    static let shared = PresenterManager()
    
    private init() {}
    
    enum vc {
        case tabBar
        case onboarding
        case login
    }
    
    private func createNavController(for rootViewController: UIViewController, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = image
        navController .navigationBar.prefersLargeTitles = false
        return navController
    }
    
    func createProfileViewController(image: UIImage) -> UIViewController {
        
        let vc = ProfileViewController()
        vc.presenter = ProfilePresenter(view: vc)
        return createNavController(for: vc, image: image)
    }
    
    func createAllFilesViewController(image: UIImage) -> UIViewController {
        
        let vc = MainViewController(requestURLstring: Constants.urlStringAllFiles, header: Constants.Text.allFiles)
        let sortDescriptors = [
            NSSortDescriptor(key: "type", ascending: true),
            NSSortDescriptor(key: "name", ascending: true)
        ]
        vc.presenter = MainPresenter(view: vc, comment: Constants.coreDataAllFiles, sortDescriptors: sortDescriptors)
        return createNavController(for: vc, image: image)
    }
    
    func createRecentsViewController(image: UIImage) -> UIViewController {
        
        let vc = MainViewController(requestURLstring: Constants.urlStringRecents, header: Constants.Text.recents)
        let sortDescriptors = NSSortDescriptor(key: "modified", ascending: false)
        vc.presenter = MainPresenter(view: vc, comment: Constants.coreDataRecents, sortDescriptors: [sortDescriptors])
        return createNavController(for: vc, image: image)
    }
    
    
    func show(vc: vc) {
        
        var viewController: UIViewController
        var viewModel: ViewModels
        let router = DefaultRouter(rootTransition: EmptyTransition())
        
        switch vc {
        case .tabBar:
            viewModel = TabBarViewModel(router: router)
            viewController = TabBarController(viewModel: viewModel as! TabBarViewModel)
        case .onboarding:
            viewModel = OnboardingViewModel(router: router)
            viewController = OnboardingViewController(viewModel: viewModel as! OnboardingViewModel)
        case .login:
            viewModel = LoginViewModel(router: router)
            let vc = LoginViewController(viewModel: viewModel as! LoginViewModel)
            viewController = UINavigationController(rootViewController: vc)
        }
        DispatchQueue.main.async {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                window.rootViewController = viewController
                UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    }
}
