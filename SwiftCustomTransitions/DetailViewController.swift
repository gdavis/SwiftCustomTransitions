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
    
    var titleFrame: CGRect {
        get {
            return self.titleLabel.frame
        }
        set {
            if self.isViewLoaded() {
                self.titleLabel.frame = newValue
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.backgroundColor = UIColor.redColor()
        self.preferredContentSize = CGSize(width: 200, height: 100)
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tapped")))
    }
    
    func tapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        self.titleLabel.frame = self.titleFrame
    }
}
