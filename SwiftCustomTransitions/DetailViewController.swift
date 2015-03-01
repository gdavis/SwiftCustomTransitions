//
//  DetailViewController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/27/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tapped")))
    }
    
    func tapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
