//
//  LoginViewModel.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

final class LoginViewModel {
    typealias Routes = LoginRoute & OnboardingRoute & Closable
    private var router: Routes

    init(router: Routes) {
        self.router = router
    }

    func dismiss() {
        router.close()
    }
}
