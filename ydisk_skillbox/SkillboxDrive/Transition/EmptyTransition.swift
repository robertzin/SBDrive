//
//  EmptyTransition.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

final class EmptyTransition: Transition {
    // MARK: - Transition
    func open(_ viewController: UIViewController, from: UIViewController, completion: (() -> Void)?) {}
    func close(_ viewController: UIViewController, completion: (() -> Void)?) {}
}
