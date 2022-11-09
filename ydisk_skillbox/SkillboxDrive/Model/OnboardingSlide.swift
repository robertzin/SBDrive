//
//  OnboardingSlide.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit

struct OnboardingSlide {
    let image: UIImage
    let description: String
    
    static let slides: [OnboardingSlide] = [
        OnboardingSlide(image: Constants.Image.onboarding1!, description: Constants.Text.onePlace),
        OnboardingSlide(image: Constants.Image.onboarding2!, description: Constants.Text.offlineAccess),
        OnboardingSlide(image: Constants.Image.onboarding3!, description: Constants.Text.shareFiles)
    ]
}
