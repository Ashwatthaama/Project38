//
//  Storyboarded.swift
//  Project38
//
//  Created by Niraj on 10/12/2019.
//  Copyright © 2019 Niraj. All rights reserved.
//

import UIKit

protocol Storyboarded {
    static func instantiate() -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let identifier = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}
