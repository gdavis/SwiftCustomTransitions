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
        static let minimum: CGFloat = 0.7, maximum: CGFloat = 2.0
    }
    
    var reverseAnimation = false
    
    
    //MARK: - <UIViewControllerAnimatedTransitioning>
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 0.5
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
    
    
    //MARK: - Animations
    
    func animateIn(transitionContext: UIViewControllerContextTransitioning)
    {
        let tableViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let detailViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!

        let containerView: UIView = transitionContext.containerView()
        let detailView = detailViewController.view
        let tableView = tableViewController.view
        
        let duration = self.transitionDuration(transitionContext)
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(detailView)
        detailView.frame = containerView.bounds
        
        detailView.alpha = 0
        detailView.transform = CGAffineTransformMakeScale(Zoom.maximum, Zoom.maximum)
        
        UIView.animateWithDuration(duration, delay:0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            detailView.alpha = 1
            detailView.transform = CGAffineTransformIdentity
            tableView.transform = CGAffineTransformMakeScale(Zoom.minimum, Zoom.minimum)
            
            }) { (animationCompleted: Bool) -> Void in
                
                // return the table view back to its original state
                tableView.transform = CGAffineTransformIdentity
                
                // when the animation is done we need to complete the transition
                transitionContext.completeTransition(animationCompleted)
        }
    }
    
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning)
    {
        let tableViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let detailViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        let detailView = detailViewController.view
        let tableView = tableViewController.view
        
        tableView.frame = transitionContext.finalFrameForViewController(tableViewController)
        tableView.alpha = 0
        tableView.transform = CGAffineTransformMakeScale(Zoom.minimum, Zoom.minimum)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            tableView.alpha = 1
            tableView.transform = CGAffineTransformIdentity
            
            detailView.alpha = 0
            detailView.transform = CGAffineTransformMakeScale(Zoom.maximum, Zoom.maximum)
            
            }) { (animationCompleted: Bool) -> Void in
                
                detailView.alpha = 1
                detailView.transform = CGAffineTransformIdentity
                
                transitionContext.completeTransition(animationCompleted)
        }
    }
}
