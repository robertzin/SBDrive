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
    
    func createRecentsViewController(image: UIImage) -> UIViewController {
        
        let view = RecentsViewController()
        let networkService = NetworkService()
        let presenter = RecentsMainPresenter(view: view, networkService: networkService)
        view.presenter = presenter

        let navController = UINavigationController(rootViewController: view)
        navController.tabBarItem.image = image
        navController .navigationBar.prefersLargeTitles = false
        
        return navController
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
