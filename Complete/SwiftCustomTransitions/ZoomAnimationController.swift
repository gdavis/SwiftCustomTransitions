//
//  TableToDetailZoomAnimation.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/27/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class ZoomAnimationController: NSObject, UIViewControllerAnimatedTransitioning
{
    private struct Zoom
    {
        static let minimum: CGFloat = 0.1, maximum: CGFloat = 5.0
    }
    
    var reverseAnimation = false
    
    
    //MARK: - <UIViewControllerAnimatedTransitioning>
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return 0.5
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if reverseAnimation {
            animateOut(transitionContext)
        }
        else {
            animateIn(transitionContext)
        }
    }
    
    
    //MARK: - Animations
    
    func animateIn(_ transitionContext: UIViewControllerContextTransitioning)
    {
        let tableViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let detailViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let containerView: UIView = transitionContext.containerView
        let detailView = detailViewController.view!
        let tableView = tableViewController.view!
        
        let duration = transitionDuration(using: transitionContext)
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(detailView)
        detailView.frame = containerView.bounds
        
        detailView.alpha = 0
        detailView.transform = CGAffineTransform(scaleX: Zoom.maximum, y: Zoom.maximum)
        
        UIView.animate(withDuration: duration, delay:0, options: .curveEaseInOut, animations: { () -> Void in
            
            detailView.alpha = 1
            detailView.transform = .identity
            tableView.transform = CGAffineTransform(scaleX: Zoom.minimum, y: Zoom.minimum)
            
        }) { (animationCompleted: Bool) -> Void in

            // return the table view back to its original state
            tableView.transform = .identity

            // when the animation is done we need to complete the transition
            transitionContext.completeTransition(animationCompleted)
        }
    }
    
    
    func animateOut(_ transitionContext: UIViewControllerContextTransitioning)
    {
        let tableViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let detailViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        let detailView = detailViewController.view!
        let tableView = tableViewController.view!
        
        tableView.frame = transitionContext.finalFrame(for: tableViewController)
        tableView.alpha = 0
        tableView.transform = CGAffineTransform(scaleX: Zoom.minimum, y: Zoom.minimum)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: .curveEaseOut, animations: { () -> Void in
            
            tableView.alpha = 1
            tableView.transform = .identity
            
            detailView.alpha = 0
            detailView.transform = CGAffineTransform(scaleX: Zoom.maximum, y: Zoom.maximum)
            
        }) { (animationCompleted: Bool) -> Void in

            detailView.alpha = 1
            detailView.transform = .identity

            transitionContext.completeTransition(animationCompleted)
        }
    }
}
