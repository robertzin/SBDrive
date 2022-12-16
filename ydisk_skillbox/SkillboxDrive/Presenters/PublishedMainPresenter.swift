//
//  PublishedMainPresenter.swift
//  SkillboxDrive
//
//  Created by Robert Zinyatullin on 06.12.2022.
//

import UIKit

protocol PublishedMainProtocol {
    func success()
    func failure()
    func imageDownloadingSuccess()
    func imageDownloadingFailure()
    func openDiskItemView(vc: UIViewController)
}

protocol PublishedMainPresenterProtocol {
    init(view: PublishedMainProtocol, networkService: NetworkServiceProtocol)
}

class PublishedMainPresenter: PublishedMainPresenterProtocol {
    var view: PublishedMainProtocol?
    var networkService: NetworkServiceProtocol!

    required init(view: PublishedMainProtocol, networkService: NetworkServiceProtocol) {
        self.view = view
        self.networkService = networkService
    }
}
