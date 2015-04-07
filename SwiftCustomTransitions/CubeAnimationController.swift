//
//  CubeAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 4/5/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class CubeAnimationController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {
    
    // constants
    let Rotation = CGFloat(M_PI_2)
    let Projection: CGFloat = 1 / -600
    let Duration: CFTimeInterval = 0.65
    
    // animation properties
    var reverseAnimation = false
    var transitionContext: UIViewControllerContextTransitioning?
    
    // interactive transition properties
    var interactive = false
    var startTouchPoint: CGPoint?
    var animationTimer: NSTimer?
    
    
    //MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return Duration
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = transitionContext.finalFrameForViewController(toViewController)
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        self.setupScene(containerView, sourceView: sourceView, destinationView: destinationView)
        
        // add animations
        var sourceViewAnimation: CABasicAnimation
        var destinationViewAnimation: CABasicAnimation
        
        if self.reverseAnimation {
            sourceViewAnimation = self.createCubeTransformAnimation(Rotation, view: sourceView, presenting: false)
            destinationViewAnimation = self.createCubeTransformAnimation(-Rotation, view: destinationView, presenting: true)
        }
        else {
            sourceViewAnimation = self.createCubeTransformAnimation(-Rotation, view: sourceView, presenting: false)
            destinationViewAnimation = self.createCubeTransformAnimation(Rotation, view: destinationView, presenting: true)
        }
        
        destinationViewAnimation.completionBlock = { (success: Bool) -> Void in
            transitionContext.completeTransition(success && !transitionContext.transitionWasCancelled())
        }
        
        sourceView.layer.addAnimation(sourceViewAnimation, forKey: sourceViewAnimation.keyPath)
        destinationView.layer.addAnimation(destinationViewAnimation, forKey: destinationViewAnimation.keyPath)
    }
    
    
    func animationEnded(transitionCompleted: Bool)
    {
        let transitionContext = self.transitionContext!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        
        if transitionCompleted == false {
            sourceView.layer.transform = CATransform3DIdentity
            destinationView.removeFromSuperview()
        }
        
        self.transitionContext = nil
        self.interactive = false
        self.interactivePopGestureRecognizer = nil
    }


    //MARK: - UIViewControllerInteractiveTransitioning
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        super.startInteractiveTransition(transitionContext)
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView = transitionContext.containerView()
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = containerView.bounds
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        self.setupScene(containerView, sourceView: sourceView, destinationView: destinationView)
        self.startTouchPoint = self.interactivePopGestureRecognizer?.locationInView(containerView)
    }
    
    
    
    override func cancelInteractiveTransition() {
        super.cancelInteractiveTransition()
        
        let transitionContext = self.transitionContext!
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        
        let sourceViewAnimation = sourceView.layer.animationForKey("transform") as! CABasicAnimation
        let destinationViewAnimation = destinationView.layer.animationForKey("transform") as! CABasicAnimation
        
        sourceView.layer.transform = (sourceViewAnimation.fromValue as! NSValue).CATransform3DValue
        destinationView.layer.transform = (destinationViewAnimation.fromValue as! NSValue).CATransform3DValue
    }
    
    
    //MARK: - Gesture Recognizer
    // this gesture is owned by the UINavigationController and is used to update the transition
    // animation as the user pans across the screen. we become the delegate and respond to its
    // actions in order to use the gesture for the transition.
    var interactivePopGestureRecognizer: UIGestureRecognizer? {
        didSet {
            self.interactivePopGestureRecognizer?.delegate = self
            self.interactivePopGestureRecognizer?.addTarget(self, action: "screenEdgeDidPan:")
        }
    }
    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if self.animationTimer != nil {
            return false
        }
        
        self.interactive = true
        return true
    }
    
    
    func screenEdgeDidPan(gesture: UIGestureRecognizer)
    {
        if let transitionContext = self.transitionContext {
            
            let containerView = transitionContext.containerView()
            let touchPoint = gesture.locationInView(containerView)
            let progress = touchPoint.x / CGRectGetWidth(containerView.frame)
            
            switch (gesture.state) {
                
            case .Changed:
                self.updateInteractiveTransition(progress)
                
                if self.reverseAnimation == false && progress >= 0.75 {
                    self.finishInteractiveTransition()
                }
                else if self.reverseAnimation && progress >= 0.95 {
                    self.finishInteractiveTransition()
                }
                break
                
            case .Ended, .Cancelled:
                if progress > 0.5 {
                    self.animateToPercentComplete(1)
                }
                else {
                    self.animateToPercentComplete(0)
                }
                break
                
            default:
                break
            }
        }
    }
    
    
    //MARK: - Animation Timer
    
    func animateToPercentComplete(percent: CGFloat)
    {
        if self.animationTimer == nil {
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self, selector: "adjustPercentComplete:", userInfo: Float(percent), repeats: true)
        }
    }
    
    
    func stopAnimationTimer()
    {
        self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
    
    
    func adjustPercentComplete(timer: NSTimer)
    {
        let targetPercent = timer.userInfo as! CGFloat
        let delta = (targetPercent - self.percentComplete) * 0.075
        
        self.updateInteractiveTransition(self.percentComplete + delta)
        
        if abs(delta) < 0.001 {
            
            self.stopAnimationTimer()
            
            if targetPercent == 1 {
                self.finishInteractiveTransition()
            }
            else {
                self.cancelInteractiveTransition()
            }
        }
    }
    
    
    //MARK: - Helpers
    
    func setupScene(containerView: UIView, sourceView: UIView, destinationView: UIView)
    {
        // setup the 3D scene by setting perspective in the container and configuring the view positions
        // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html#//apple_ref/doc/uid/TP40004514-CH8-SW13
        var containerTransform = CATransform3DIdentity
        containerTransform.m34 = Projection
        containerView.layer.sublayerTransform = containerTransform
        
        // calculate the z-distance as a ratio of the width of the container. 
        // this keeps the edges of the cube sides aligned when rotating
        let z = -(0.5 * CGRectGetWidth(self.transitionContext!.containerView().frame))
        sourceView.layer.zPosition = z
        sourceView.layer.anchorPointZ = z
        destinationView.layer.zPosition = z
        destinationView.layer.anchorPointZ = z
    }
    
    
    func createCubeTransformAnimation(rotation: CGFloat, view: UIView, presenting: Bool) -> CABasicAnimation
    {
        let viewFromTransform = CATransform3DMakeRotation(rotation, 0, 1, 0)
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        
        if presenting {
            transformAnimation.fromValue = NSValue(CATransform3D: viewFromTransform)
            transformAnimation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
            view.layer.transform = CATransform3DIdentity
        }
        else {
            transformAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
            transformAnimation.toValue = NSValue(CATransform3D: viewFromTransform)
            view.layer.transform = viewFromTransform
        }
        
        transformAnimation.duration = Duration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return transformAnimation
    }
}
