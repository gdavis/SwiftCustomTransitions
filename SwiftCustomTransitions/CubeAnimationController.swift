//
//  CubeAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 4/5/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class CubeAnimationController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {

    
    var reverseAnimation: Bool = false
    
    
    //MARK: - UIViewControllerAnimatedTransitioning
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return 1.0
    }
    
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        println("CubeAnimationController - animateTransition")
        if self.reverseAnimation {
            self.animateOut(transitionContext)
        }
        else {
            self.animateIn(transitionContext)
        }
    }
    
    
    // This is a convenience and if implemented will be invoked by the system when the transition context's completeTransition: method is invoked.
    func animationEnded(transitionCompleted: Bool)
    {
        
    }


    //MARK: - UIViewControllerInteractiveTransitioning
    
    func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        println("CubeAnimationController - startInteractiveTransition")
        let containerView: UIView = transitionContext.containerView()
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipe"))
        containerView.addGestureRecognizer(swipeGesture)
    }
    
    
    func completionSpeed() -> CGFloat
    {
        return 1.0
    }
    
    
    func completionCurve() -> UIViewAnimationCurve
    {
        return UIViewAnimationCurve.Linear
    }
    
    
    //MARK: - Animation
    
    func animateIn(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        
        let containerView: UIView = transitionContext.containerView()
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = containerView.bounds
        
        let containerWidth = CGRectGetWidth(containerView.bounds)
        let anchorPointZ: CGFloat = -188
        let rotation: CGFloat = CGFloat(M_PI_2)
        let projection: CGFloat = 1.0 / -600
        let duration: CFTimeInterval = 1.0
        
        // setup container view with perspective for child layers
        
        var containerTransform = CATransform3DIdentity
        containerTransform.m34 = projection
        containerView.layer.sublayerTransform = containerTransform
        
        
        // source view animations
        
        let sourceViewToTransform = CATransform3DMakeRotation(-rotation, 0.0, 1.0, 0.0)
        let sourceViewTransformAnimation = CABasicAnimation(keyPath: "transform")
        sourceViewTransformAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
        sourceViewTransformAnimation.toValue = NSValue(CATransform3D: sourceViewToTransform)
        sourceViewTransformAnimation.duration = duration
        sourceViewTransformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        sourceViewTransformAnimation.completionBlock = { (finished: Bool) -> Void in
            transitionContext.completeTransition(true)
        }
        sourceView.layer.zPosition = anchorPointZ
        sourceView.layer.anchorPointZ = anchorPointZ
        sourceView.layer.addAnimation(sourceViewTransformAnimation, forKey: "cubeFromViewAnimation")
        

        // destination view animations
        
        let destinationViewFromTransform = CATransform3DMakeRotation(rotation, 0.0, 1.0, 0.0)
        let toViewTransformAnimation = CABasicAnimation(keyPath: "transform")
        toViewTransformAnimation.fromValue = NSValue(CATransform3D: destinationViewFromTransform)
        toViewTransformAnimation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        toViewTransformAnimation.duration = duration
        toViewTransformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        destinationView.layer.zPosition = anchorPointZ
        destinationView.layer.anchorPointZ = anchorPointZ
        destinationView.layer.addAnimation(toViewTransformAnimation, forKey: "cubeToVewAnimation")
    }
    
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning)
    {
        
    }
    
    
    func handleSwipe(gesture: UISwipeGestureRecognizer)
    {
        println("Swiping!!")
    }
}
