//
//  DefaultRouter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

class DefaultRouter: NSObject, Router, Closable, Dismissable {
    private let rootTransition: Transition
    weak var root: UIViewController?

    init(rootTransition: Transition) {
        self.rootTransition = rootTransition
    }

    // MARK: - Routable
    func route(to viewController: UIViewController, as transition: Transition, completion: (() -> Void)?) {
        guard let root = root else { return }
        transition.open(viewController, from: root, completion: completion)
    }

    func route(to viewController: UIViewController, as transition: Transition) {
        route(to: viewController, as: transition, completion: nil)
    }

    // MARK: - Closable
    func close(completion: (() -> Void)?) {
        guard let root = root else { return }
        rootTransition.close(root, completion: completion)
    }

    func close() {
        close(completion: nil)
    }

    // MARK: - Dismissable
    func dismiss(completion: (() -> Void)?) {
        root?.dismiss(animated: true, completion: completion)
    }

    func dismiss() {
        dismiss(completion: nil)
    }
}
