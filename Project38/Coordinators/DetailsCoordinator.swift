//
//  DetailsCoordinator.swift
//  Project38
//
//  Created by Niraj on 10/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit

class DetailsCoordinator: Coordinator {

    var parentCoordinator: MainCoordinator?

     var detailItem: Commit?

    var childCoordinators: [Coordinator] = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = DetailViewController.instantiate()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
}
