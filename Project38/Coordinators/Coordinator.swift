//
//  Coordinator.swift
//  Project38
//
//  Created by Niraj on 10/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit

protocol Coordinator {

    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
}
