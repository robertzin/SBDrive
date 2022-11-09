//
//  LoadingRoute.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

protocol LoadingRoute {
    func makeLoadingView() -> UIViewController
}

extension LoadingRoute where Self: Router {
    func makeLoadingView() -> UIViewController {
        let router = DefaultRouter(rootTransition: EmptyTransition())
        let viewModel = LoadingViewModel(router: router)
        let viewController = LoadingViewController(viewModel: viewModel)
        
        router.root = viewController
        return viewController
    }
}

extension DefaultRouter: LoadingRoute {}
