//
//  PopupViewController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/28/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController, UIViewControllerTransitioningDelegate
{
    //MARK: - UIViewController
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.preferredContentSize = CGSize(width: 200, height: 100)
        self.view.clipsToBounds = true
        self.view.layer.cornerRadius = 4
        self.view.layer.borderColor = UIColor.blueColor().CGColor
        self.view.layer.borderWidth = 2
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("tapped")))
    }
    
    func tapped()
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
