//
//  SpaceViewController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 8/14/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class SpaceViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.quoteLabel.alpha = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.quoteLabel.alpha = 1
        })
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.quoteLabel.alpha = 0
            }) { (finished: Bool) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
