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
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    
    //MARK: - <UIViewControllerTransitioningDelegate>
    
    lazy var popupAnimation = PopupAnimationController()

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        popupAnimation.reverseAnimation = false
        return popupAnimation
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        popupAnimation.reverseAnimation = true
        return popupAnimation
    }
    
    
    //MARK: - UIViewController
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 200, height: 100)
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        view.layer.borderColor = UIColor.blue.cgColor
        view.layer.borderWidth = 2
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    @objc func tapped()
    {
        dismiss(animated: true, completion: nil)
    }
}
