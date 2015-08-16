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
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .Custom
    }
    
    
    //MARK: - <UIViewControllerTransitioningDelegate>
    
    lazy var popupAnimation = PopupAnimationController()
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.popupAnimation.reverseAnimation = false
        return self.popupAnimation
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        self.popupAnimation.reverseAnimation = true
        return self.popupAnimation
    }
    
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
