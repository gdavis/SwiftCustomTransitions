//
//  CubeDetailViewController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 4/5/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class CubeDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.layer.borderColor = UIColor.redColor().CGColor
        self.view.layer.borderWidth = 4.0
    }
}
