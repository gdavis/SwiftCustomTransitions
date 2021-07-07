//
//  ImageAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 8/14/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class ImageAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    
    var reverseAnimation = false
    
    lazy var animationImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .center
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    //MARK: - <UIViewControllerAnimatedTransitioning>
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval   {
        if self.reverseAnimation {
            return 0.4
        }
        return 0.6
    }
    
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        if self.reverseAnimation {
            animateOut(transitionContext: transitionContext)
        }
        else {
            animateIn(transitionContext: transitionContext)
        }
    }
    
    func animateIn(transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = self.transitionDuration(using: transitionContext)
        
        // pull out values we need from the context
        let tableNavigationController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! UINavigationController
        let tableViewController = tableNavigationController.topViewController as! TransitionsTableView
        let imageViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ImageViewController
        let containerView = transitionContext.containerView
        let destinationViewFrame = transitionContext.finalFrame(for: imageViewController)
        
        // size the destination view
        imageViewController.view.frame = destinationViewFrame
        containerView.addSubview(imageViewController.view)
        containerView.layoutIfNeeded()
        
        // hide the destination view until the image animates into place
        imageViewController.view.isHidden = true
        
        // get a reference to the cell's image view
        let indexPath = NSIndexPath(row: 3, section: 0)
        let spaceCell = tableViewController.tableView.cellForRow(at: indexPath as IndexPath)!
        let cellImageView = spaceCell.contentView.subviews.last as! UIImageView
        
        // configure the animation image view with the cell's image and frame
        animationImageView.image = cellImageView.image
        animationImageView.frame = cellImageView.convert(cellImageView.bounds, to: containerView)
        containerView.addSubview(animationImageView)
        
        // fade in the animation image
        animationImageView.alpha = 0
        UIView.animate(withDuration: duration * 0.25, delay: 0, options: .curveEaseOut, animations: { [unowned self] in
            
            self.animationImageView.alpha = 1
            
        }, completion: nil)
        
        // size the image to match the destination view frame
        let destinationImageFrame = imageViewController.imageView.convert(imageViewController.imageView.bounds, to: containerView)
        
        UIView.animate(withDuration: duration * 0.75, delay: duration * 0.25, options: .curveEaseInOut, animations: { [unowned self]  in
            
            // resize the image to match the size of the destination view
            self.animationImageView.frame = destinationImageFrame
            
        }, completion: { [unowned self] (finished: Bool) -> Void in

            // remove the transition image view
            self.animationImageView.removeFromSuperview()

            // show the destination view
            imageViewController.view.isHidden = false

            // finish the transition
            transitionContext.completeTransition(true)
        })
    }
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning) {
        
        let duration = transitionDuration(using: transitionContext)
        
        // pull out values we need from the context
        let tableNavigationController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! UINavigationController
        let tableViewController = tableNavigationController.topViewController as! TransitionsTableView
        let imageViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ImageViewController
        let containerView = transitionContext.containerView
        
        // get a reference to the cell's image view
        let indexPath = NSIndexPath(row: 3, section: 0)
        let spaceCell = tableViewController.tableView.cellForRow(at: indexPath as IndexPath)!
        let cellImageView = spaceCell.contentView.subviews.last as! UIImageView
        
        // configure the animation image view with the cell's image and frame
        animationImageView.image = cellImageView.image
        animationImageView.frame = imageViewController.imageView.convert(imageViewController.imageView.bounds, to: containerView)
        
        // remove the view we're transitioning from
        imageViewController.view.removeFromSuperview()
        
        // place the animation image on top
        containerView.addSubview(animationImageView)
        
        // resize the animation image to match the cell image view's frame
        let destinationImageFrame = cellImageView.convert(cellImageView.bounds, to: containerView)
        
        UIView.animate(withDuration: duration * 0.75, delay: 0, options: .curveEaseInOut, animations: { [unowned self] in
            
            self.animationImageView.frame = destinationImageFrame
            
        }, completion: nil)
        
        // fade out the animation image and end the transition
        UIView.animate(withDuration: duration * 0.25, delay: duration * 0.75, options: .curveEaseInOut, animations: { [unowned self] in
            
            self.animationImageView.alpha = 0
            
        }, completion: { [unowned self] (finished: Bool) -> Void in

            self.animationImageView.removeFromSuperview()

            transitionContext.completeTransition(true)
        })
    }
}
