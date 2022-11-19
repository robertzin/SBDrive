//
//  TabBarRoute.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 11.11.2022.
//

import UIKit

protocol TabBarRoute {
    func openTabBar()
}

extension TabBarRoute where Self: Router {
    func openTabBar(with transition: Transition) {
        let router = DefaultRouter(rootTransition: transition)
        let viewModel = TabBarViewModel(router: router)
        let viewController = TabBarController(viewModel: viewModel)
        router.root = viewController

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem = UITabBarItem(title: "New Transition", image: nil, tag: 0)
        
        router.root = viewController
        route(to: navigationController, as: transition)
    }
    
    func openTabBar() {
        openTabBar(with: AnimatedTransition(animatedTransition: FadeAnimatedTransitioning()))
    }

    func selectListTab() {
        root?.tabBarController?.selectedIndex = 0
    }
}

extension DefaultRouter: TabBarRoute {}
