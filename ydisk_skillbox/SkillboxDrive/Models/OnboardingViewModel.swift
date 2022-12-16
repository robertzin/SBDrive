//
//  OnboardingViewModel.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

final class OnboardingViewModel: ViewModels {
    typealias Routes = OnboardingRoute & LoginRoute & Closable
    private let router: Routes

    init(router: Routes) {
        self.router = router
    }

    func login() {
        router.openLogin()
    }

    func close() {
        router.close()
    }
}
