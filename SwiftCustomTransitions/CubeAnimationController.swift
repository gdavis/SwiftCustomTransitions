//
//  CubeAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 4/5/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class CubeAnimationController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {

    static let AnchorPointZ: CGFloat = -188
    static let Projection: CGFloat = 1.0 / -600
    static let Rotation: CGFloat = CGFloat(M_PI_2)
    static let Duration: CFTimeInterval = 1.0
    
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
        
        // setup container view with perspective for child layers
        
        var containerTransform = CATransform3DIdentity
        containerTransform.m34 = CubeAnimationController.Projection
        containerView.layer.sublayerTransform = containerTransform
        
        // add animations
        
        let fromViewAnimation = self.createCubeTransformAnimation(-CubeAnimationController.Rotation, view: sourceView, presenting: false)
        let toViewAnimation = self.createCubeTransformAnimation(CubeAnimationController.Rotation, view: destinationView, presenting: true)
        toViewAnimation.completionBlock = { (success: Bool) -> Void in
            transitionContext.completeTransition(success)
        }
        
        sourceView.layer.addAnimation(fromViewAnimation, forKey: "fromViewCubeAnimation")
        destinationView.layer.addAnimation(toViewAnimation, forKey: "toViewCubeAnimation")
    }

    
    
    func animateOut(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        let containerView: UIView = transitionContext.containerView()
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = containerView.bounds
        
        // setup container view with perspective for child layers
        
        var containerTransform = CATransform3DIdentity
        containerTransform.m34 = CubeAnimationController.Projection
        containerView.layer.sublayerTransform = containerTransform
        
        // add animations
        
        let fromViewAnimation = self.createCubeTransformAnimation(CubeAnimationController.Rotation, view: sourceView, presenting: false)
        let toViewAnimation = self.createCubeTransformAnimation(-CubeAnimationController.Rotation, view: destinationView, presenting: true)
        
        toViewAnimation.completionBlock = { (success: Bool) -> Void in
            transitionContext.completeTransition(success)
        }
        
        sourceView.layer.addAnimation(fromViewAnimation, forKey: "fromViewCubeAnimation")
        destinationView.layer.addAnimation(toViewAnimation, forKey: "toViewCubeAnimation")
    }
    
    
    func createCubeTransformAnimation(rotation: CGFloat, view: UIView, presenting: Bool) -> CABasicAnimation
    {
        let viewFromTransform = CATransform3DMakeRotation(rotation, 0.0, 1.0, 0.0)
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        
        if presenting {
            transformAnimation.fromValue = NSValue(CATransform3D: viewFromTransform)
            transformAnimation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        }
        else
        {
            transformAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
            transformAnimation.toValue = NSValue(CATransform3D: viewFromTransform)
        }
        
        transformAnimation.duration = CubeAnimationController.Duration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        view.layer.zPosition = CubeAnimationController.AnchorPointZ
        view.layer.anchorPointZ = CubeAnimationController.AnchorPointZ
        
        return transformAnimation
    }
    
    
    func handleSwipe(gesture: UISwipeGestureRecognizer)
    {
        println("Swiping!!")
    }
}
