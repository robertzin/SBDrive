//
//  OnboardingCollectionViewCell.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 09.11.2022.
//

import UIKit
import SnapKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    private lazy var image: UIImageView = {
        var imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.font = Constants.Fonts.header2
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        return textLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        contentView.addSubview(image)
        contentView.addSubview(textLabel)
    }
    
    func set(to model: OnboardingSlide) {
        image.image = model.image
        textLabel.text = model.description
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        image.frame = CGRect(x: contentView.frame.minX,
                             y: contentView.frame.minY,
                             width: contentView.frame.size.width,
                             height: contentView.frame.size.height)
        
        textLabel.frame = CGRect(x: (contentView.frame.width - 220) / 2,
                                 y: contentView.frame.maxY - 120,
                                 width: 220,
                                 height: 38)
    }
}
