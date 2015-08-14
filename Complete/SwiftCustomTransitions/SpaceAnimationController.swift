//
//  SpaceAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 8/14/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class SpaceAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
   
    
    var reverseAnimation = false
    
    lazy var animationImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRectZero)
        imageView.contentMode = .Center
        imageView.clipsToBounds = true
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return imageView
    }()
    
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
    
    func animateIn(transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = self.transitionDuration(transitionContext)
        
        let tableNavigationController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController
        let tableViewController = tableNavigationController.topViewController as! TransitionsTableView
        let spaceViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! SpaceViewController
        let containerView = transitionContext.containerView()
        
        let destinationViewFrame = transitionContext.finalFrameForViewController(spaceViewController)
        
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        let spaceCell = tableViewController.tableView.cellForRowAtIndexPath(indexPath)!
        
        let cellImageView = spaceCell.contentView.subviews.first as! UIImageView
        
        containerView.addSubview(spaceViewController.view)
        containerView.layoutIfNeeded()
        
        self.animationImageView.image = cellImageView.image
        self.animationImageView.frame = cellImageView.convertRect(cellImageView.bounds, toView: containerView)
        containerView.addSubview(self.animationImageView)
        
        spaceViewController.view.frame = destinationViewFrame
        
        spaceViewController.view.hidden = true
        
        let destinationImageFrame = spaceViewController.imageView.convertRect(spaceViewController.imageView.bounds, toView: containerView)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.animationImageView.frame = destinationImageFrame
            }, completion: { (finished: Bool) -> Void in
                
                // remove the transition image view and show the destination view
                self.animationImageView.removeFromSuperview()
                
                spaceViewController.view.hidden = false
                
                transitionContext.completeTransition(true)
        })
    }
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning) {
        let duration = self.transitionDuration(transitionContext)
        
        let tableNavigationController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UINavigationController
        let tableViewController = tableNavigationController.topViewController as! TransitionsTableView
        let spaceViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! SpaceViewController
        let containerView = transitionContext.containerView()
        
        let indexPath = NSIndexPath(forRow: 3, inSection: 0)
        let spaceCell = tableViewController.tableView.cellForRowAtIndexPath(indexPath)!
        
        let cellImageView = spaceCell.contentView.subviews.first as! UIImageView
        
        self.animationImageView.image = cellImageView.image
        self.animationImageView.frame = spaceViewController.imageView.convertRect(spaceViewController.imageView.bounds, toView: containerView)
        
        // remove the view we're transitioning from
        spaceViewController.view.removeFromSuperview()
        
        // place the image view on top
        containerView.addSubview(self.animationImageView)
        
        let destinationImageFrame = cellImageView.convertRect(cellImageView.bounds, toView: containerView)
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            
            self.animationImageView.frame = destinationImageFrame
            
            }, completion: { (finished: Bool) -> Void in
                
                // remove the transition image view
                self.animationImageView.removeFromSuperview()
                
                transitionContext.completeTransition(true)
        })
    }
}
