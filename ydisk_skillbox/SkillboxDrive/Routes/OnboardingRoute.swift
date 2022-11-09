//
//  OnboardingRoute.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

protocol OnboardingRoute {
    func openOnboarding()
}

extension OnboardingRoute where Self: Router {
    func openOnboarding(with transition: Transition) {
        let router = DefaultRouter(rootTransition: transition)
        let viewModel = OnboardingViewModel(router: router)
        let viewController = OnboardingViewController(viewModel: viewModel)
        router.root = viewController
        route(to: viewController, as: transition)
    }

    func openOnboarding() {
        openOnboarding(with: AnimatedTransition(animatedTransition: FadeAnimatedTransitioning()))
    }
}

extension DefaultRouter: OnboardingRoute {}
