//
//  LoadingViewModel.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

protocol ViewModels {}

final class LoadingViewModel: ViewModels {
    typealias Routes = OnboardingRoute & LoginRoute & TabBarRoute & Closable
    private let router: Routes

    init(router: Routes) {
        self.router = router
    }

    func login() {
        router.openLogin()
    }
    
    func onboarding() {
        router.openOnboarding()
    }

    func close() {
        router.close()
    }
    
    func openTabBar() {
        router.openTabBar()
    }
}
