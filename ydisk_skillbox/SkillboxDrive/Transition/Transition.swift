//
//  Transition.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 07.11.2022.
//

import UIKit

protocol Transition: AnyObject {
    func open(_ viewController: UIViewController, from: UIViewController, completion: (() -> Void)?)
    func close(_ viewController: UIViewController, completion: (() -> Void)?)
}
