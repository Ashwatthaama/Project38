//
//  DetailViewController.swift
//  Project38
//
//  Created by Niraj on 03/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, Storyboarded {

    var coordinator: DetailsCoordinator?
    
    @IBOutlet weak var detailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let detail = coordinator?.detailItem {
            detailLabel.text = detail.message
        }
    }


}
