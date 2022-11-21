//
//  TabBarViewModel.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 11.11.2022.
//

import UIKit

final class TabBarViewModel: ViewModels {
    typealias Routes = TabBarRoute & LoginRoute & Closable
    private let router: Routes

    init(router: Routes) {
        self.router = router
    }

    func login() {
        router.openLogin()
    }
    
    func openTapBar() {
        router.openTabBar()
    }
    
    func close() {
        router.close()
    }
}
