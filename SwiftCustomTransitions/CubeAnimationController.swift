//
//  CubeAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 4/5/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class CubeAnimationController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate {

    static let AnchorPointZ: CGFloat = -187.5
    static let Projection: CGFloat = 1.0 / -600
    static let Rotation: CGFloat = CGFloat(M_PI_2)
    static let Duration: CFTimeInterval = 0.75
    static let SourceViewAnimationKey: String = "SourceViewAnimationKey"
    static let DestinationViewAnimationKey: String = "DestinationViewAnimationKey"
    
    var reverseAnimation: Bool = false
    var interactive: Bool = false
    var startTouchPoint: CGPoint?
    var animationTimer: NSTimer?
    var transitionContext: UIViewControllerContextTransitioning?
    
    
    //MARK: - Setup
    
    override init() {
        super.init()
        self.completionSpeed = 1.0
        self.completionCurve = UIViewAnimationCurve.EaseInOut
    }
    
    
    //MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval
    {
        return CubeAnimationController.Duration
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        let containerView = transitionContext.containerView()
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = transitionContext.finalFrameForViewController(toViewController)
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        self.setupScene(containerView, sourceView: sourceView, destinationView: destinationView)
        
        // add animations
        var toViewAnimation: CAAnimation
        var fromViewAnimation: CAAnimation
        
        if self.reverseAnimation {
            fromViewAnimation = self.createCubeTransformAnimation(CubeAnimationController.Rotation, view: sourceView, presenting: false)
            toViewAnimation = self.createCubeTransformAnimation(-CubeAnimationController.Rotation, view: destinationView, presenting: true)
        }
        else {
            fromViewAnimation = self.createCubeTransformAnimation(-CubeAnimationController.Rotation, view: sourceView, presenting: false)
            toViewAnimation = self.createCubeTransformAnimation(CubeAnimationController.Rotation, view: destinationView, presenting: true)
        }
        
        toViewAnimation.completionBlock = { (success: Bool) -> Void in
            transitionContext.completeTransition(success && !transitionContext.transitionWasCancelled())
        }
        
        sourceView.layer.addAnimation(fromViewAnimation, forKey: CubeAnimationController.SourceViewAnimationKey)
        destinationView.layer.addAnimation(toViewAnimation, forKey: CubeAnimationController.DestinationViewAnimationKey)
    }
    
    
    func animationEnded(transitionCompleted: Bool)
    {
        if let transitionContext = self.transitionContext {
            
            let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let sourceView = fromViewController.view
            let destinationView = toViewController.view
            sourceView.layer.removeAllAnimations()
            destinationView.layer.removeAllAnimations()
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
        
        // store references
        self.transitionContext = transitionContext
        self.startTouchPoint = self.interactivePopGestureRecognizer?.locationInView(containerView)
    }
    
    
    //MARK: - Gesture Recognizer
    
    var interactivePopGestureRecognizer: UIGestureRecognizer? {
        didSet {
            self.interactivePopGestureRecognizer?.addTarget(self, action: "screenEdgeDidPan:")
            self.interactivePopGestureRecognizer?.delegate = self
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
                    self.animateToProgress(1.0)
                }
                else {
                    self.animateToProgress(0.0)
                }
                break
                
            default:
                break
            }
        }
    }
    
    
    //MARK: - Cube Animation
    
    func createCubeTransformAnimation(rotation: CGFloat, view: UIView, presenting: Bool) -> CABasicAnimation
    {
        let viewFromTransform = CATransform3DMakeRotation(rotation, 0.0, 1.0, 0.0)
        let transformAnimation = CABasicAnimation(keyPath: "transform")
        
        if presenting {
            transformAnimation.fromValue = NSValue(CATransform3D: viewFromTransform)
            transformAnimation.toValue = NSValue(CATransform3D: CATransform3DIdentity)
        }
        else {
            transformAnimation.fromValue = NSValue(CATransform3D: CATransform3DIdentity)
            transformAnimation.toValue = NSValue(CATransform3D: viewFromTransform)
        }
        
        transformAnimation.fillMode = kCAFillModeRemoved
        transformAnimation.duration = CubeAnimationController.Duration
        transformAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        return transformAnimation
    }
    
    
    //MARK: - Cancel
    
    func animateToProgress(progress: CGFloat)
    {
        if self.animationTimer == nil {
            self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(1.0/60.0, target: self, selector: "adjustProgress:", userInfo: Float(progress), repeats: true)
        }
    }
    
    
    func stopAnimationTimer()
    {
        self.animationTimer?.invalidate()
        self.animationTimer = nil
    }
    
    
    func adjustProgress(timer: NSTimer)
    {
        let targetPercent = timer.userInfo as! CGFloat
        let delta = (targetPercent - self.percentComplete) * 0.05
        
        self.updateInteractiveTransition(self.percentComplete + delta)
        
        if abs(delta) < 0.002 {
            
            if targetPercent == 1.0 {
                self.finishInteractiveTransition()
            }
            else {
                self.cancelInteractiveTransition()
            }
            
            self.stopAnimationTimer()
        }
    }
    
    
    //MARK: - Helpers
    
    func setupScene(containerView: UIView, sourceView: UIView, destinationView: UIView)
    {
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        var containerTransform = CATransform3DIdentity
        containerTransform.m34 = CubeAnimationController.Projection
        containerView.layer.sublayerTransform = containerTransform
        
        sourceView.layer.zPosition = CubeAnimationController.AnchorPointZ
        sourceView.layer.anchorPointZ = CubeAnimationController.AnchorPointZ
        
        destinationView.layer.zPosition = CubeAnimationController.AnchorPointZ
        destinationView.layer.anchorPointZ = CubeAnimationController.AnchorPointZ
    }
}
