//
//  PopupAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/28/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class PopupAnimationController: NSObject, UIViewControllerAnimatedTransitioning
{
    var reverseAnimation: Bool = false
    let dimmerView: UIView
    
    override init() {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor .blackColor().colorWithAlphaComponent(0.8)
        self.dimmerView = view
    }
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 1.25
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        if self.reverseAnimation {
            animateOut(transitionContext)
        }
        else {
            animateIn(transitionContext)
        }
    }
    
    
    func animateIn(transitionContext: UIViewControllerContextTransitioning)
    {
        let duration = self.transitionDuration(transitionContext)
        let containerView = transitionContext.containerView()
        let popupViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let popupView = popupViewController.view
        
        containerView.addSubview(self.dimmerView)
        popupView.frame = CGRect(origin: CGPointZero, size: popupViewController.preferredContentSize)
        popupView.center = containerView.center
        
        let scaleValues: [NSValue] = [
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 1)),
            NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
            NSValue(CATransform3D: CATransform3DMakeScale(0.9, 0.9, 1)),
            NSValue(CATransform3D: CATransform3DIdentity)
        ]
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.duration = duration * 0.7
        transformAnimation.values = scaleValues
        transformAnimation.keyTimes = [0, 0.4, 0.7, 1]
        transformAnimation.fillMode = kCAFillModeBoth
        transformAnimation.timingFunctions = [
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut),
        ]
        transformAnimation.completionBlock = { (finished: Bool) -> Void in
            transitionContext.completeTransition(finished)
        }
        
        let dimmerFadeAnimation = CABasicAnimation(keyPath: "opacity")
        dimmerFadeAnimation.fromValue = 0
        dimmerFadeAnimation.toValue = 1
        dimmerFadeAnimation.duration = duration * 0.3
        dimmerFadeAnimation.fillMode = kCAFillModeBoth
        dimmerFadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        dimmerFadeAnimation.completionBlock = { (finished: Bool) -> Void in
            if finished {
                containerView.addSubview(popupView)
                popupView.layer.addAnimation(transformAnimation, forKey: "transformAnimation")
            }
            else {
                transitionContext.completeTransition(finished)
            }
        }
        
        self.dimmerView.frame = containerView.bounds
        self.dimmerView.layer.addAnimation(dimmerFadeAnimation, forKey: "dimmerFadeAnimation")
    }
    
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning)
    {
        let duration = self.transitionDuration(transitionContext)
        let popupViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let popupView = popupViewController.view
        
        let dimmerFadeAnimation = CABasicAnimation(keyPath: "opacity")
        dimmerFadeAnimation.fromValue = 1
        dimmerFadeAnimation.toValue = 0
        dimmerFadeAnimation.duration = duration * 0.4
        dimmerFadeAnimation.fillMode = kCAFillModeBoth
        dimmerFadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        dimmerFadeAnimation.completionBlock = { (finished: Bool) -> Void in
            transitionContext.completeTransition(finished)
        }
        
        let scaleValues: [NSValue] = [
            NSValue(CATransform3D: CATransform3DIdentity),
            NSValue(CATransform3D: CATransform3DMakeScale(1.2, 1.2, 1)),
            NSValue(CATransform3D: CATransform3DMakeScale(0, 0, 1)),
        ]
        
        let transformAnimation = CAKeyframeAnimation(keyPath: "transform")
        transformAnimation.duration = duration * 0.6
        transformAnimation.values = scaleValues
        transformAnimation.keyTimes = [0, 0.7, 1]
        transformAnimation.fillMode = kCAFillModeBoth
        transformAnimation.timingFunctions = [
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),
            CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn),
        ]
        transformAnimation.completionBlock = { (finished: Bool) -> Void in
            if finished {
                self.dimmerView.layer.addAnimation(dimmerFadeAnimation, forKey: "fadeAnimation")
            }
            else {
                transitionContext.completeTransition(finished)
            }
        }
        
        popupView.layer.addAnimation(transformAnimation, forKey: "transformAnimation")
    }
    
}