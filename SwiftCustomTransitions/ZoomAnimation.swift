//
//  TableToDetailZoomAnimation.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/27/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class ZoomAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    let reverseAnimation: Bool
    
    init(isReverseAnimation: Bool) {
        self.reverseAnimation = isReverseAnimation
        super.init()
    }

    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 0.5
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        if self.reverseAnimation {
            animateOut(transitionContext)
        }
        else {
            animateIn(transitionContext)
        }
    }
    
    // This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
    func animationEnded(transitionCompleted: Bool)
    {
        println("we did it!")
    }
    
    //MARK: - Animations
    
    func animateIn(transitionContext: UIViewControllerContextTransitioning) {
        let tableViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! TransitionsTableView
        let detailViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! DetailViewController
        
        // viewForKey is iOS8+ and only necessary when a system-provided presentation controller installs another view underneath the presented view controller’s view.
        //   let detailView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        //   let tableView = transitionContext.viewForKey(UITransitionContextFromViewKey) as! UITableView
        // for most cases, we just access the view's from their VC.
        let detailView = detailViewController.view
        let tableView = tableViewController.tableView
        
        let containerView: UIView = transitionContext.containerView()
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(detailView)
        detailView.frame = containerView.bounds
        
        detailView.alpha = 0.0
        detailView.transform = CGAffineTransformMakeScale(2, 2)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay:0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            detailView.alpha = 1.0
            detailView.transform = CGAffineTransformIdentity
            
            tableView.transform = CGAffineTransformMakeScale(0.2, 0.2)
            
            }) { (animationCompleted: Bool) -> Void in
                
                // return things back to normal
                tableView.transform = CGAffineTransformIdentity
                
                // finally, tell the context we are done
                transitionContext.completeTransition(animationCompleted)
        }
    }
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning) {
        let tableViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! TransitionsTableView
        let detailViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! DetailViewController
        
        let detailView = detailViewController.view
        let tableView = tableViewController.tableView
        
        // note: for dismissal, you do not need to add the "to view" to the container.
        
        tableView.frame = transitionContext.finalFrameForViewController(tableViewController)
        tableView.alpha = 0.0
        tableView.transform = CGAffineTransformMakeScale(0.2, 0.2)
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            
            tableView.alpha = 1.0
            tableView.transform = CGAffineTransformIdentity
            
            detailView.transform = CGAffineTransformMakeScale(2.0, 2.0)
            detailView.alpha = 0
            
            }) { (animationCompleted: Bool) -> Void in
                
                detailView.transform = CGAffineTransformIdentity
                detailView.alpha = 1
                
                transitionContext.completeTransition(animationCompleted)
        }
    }
}
