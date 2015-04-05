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
    
    var reverseAnimation: Bool = false
    var interactive: Bool = false
    var startTouchPoint: CGPoint?
    
    var interactiveContainerView: UIView?
    var sourceView: UIView?
    var destinationView: UIView?
    
    var interactivePopGestureRecognizer: UIGestureRecognizer? {
        didSet {
            self.interactivePopGestureRecognizer?.addTarget(self, action: "screenEdgeDidPan:")
            self.interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    
    override init() {
        super.init()
        self.completionSpeed = 1.0
        self.completionCurve = UIViewAnimationCurve.EaseInOut
    }
    
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        self.interactive = true
        return true
    }
    
    
    func screenEdgeDidPan(gesture: UIGestureRecognizer)
    {
        println("screenEdgeDidPan")
        
        if let containerView = self.interactiveContainerView {
            
            let touchPoint = gesture.locationInView(containerView)
            var progress: CGFloat = touchPoint.x / CGRectGetWidth(containerView.frame)
            
            switch (gesture.state) {
                
            case .Ended, .Cancelled:
                
                // TODO: finish interactive cancelation animation
                if progress > 0.5 {
                    
                     // finish the animation
//                    
//                    let fromViewAnimation = self.createCubeTransformAnimation(-CubeAnimationController.Rotation, view: self.sourceView!, presenting: false)
//                    let toViewAnimation = self.createCubeTransformAnimation(CubeAnimationController.Rotation, view: self.destinationView!, presenting: true)
//                    
//                    let sourceViewTransform = CATransform3DMakeRotation(-CubeAnimationController.Rotation * progress, 0.0, 1.0, 0.0)
//                    let destinationViewTransform = CATransform3DMakeRotation(CubeAnimationController.Rotation * progress, 0.0, 1.0, 0.0)
//                    
//                    fromViewAnimation.fromValue = NSValue(CATransform3D: self.sourceView!.layer.transform)
////                    fromViewAnimation.duration = (1.0 - CFTimeInterval(progress)) * fromViewAnimation.duration
//                    
//                    toViewAnimation.fromValue = NSValue(CATransform3D: self.destinationView!.layer.transform)
////                    toViewAnimation.duration = (1.0 - CFTimeInterval(progress)) * fromViewAnimation.duration
//                    
//                    self.sourceView?.layer.transform = CATransform3DIdentity
//                    self.destinationView?.layer.transform = CATransform3DIdentity
//                    
//                    toViewAnimation.completionBlock = { (success: Bool) -> Void in
//                    
////                        self.finishInteractiveTransition()
//                    }
//                    
//                    self.sourceView?.layer.addAnimation(fromViewAnimation, forKey: "finishCubeTransition")
//                    self.destinationView?.layer.addAnimation(toViewAnimation, forKey: "finishCubeTransition")
                }
                else {
                    
                }
                break
                
            default:
                self.updateInteractiveTransition(progress)
                break
            }
        }
    }
    
    
    override func updateInteractiveTransition(percentComplete: CGFloat)
    {
        super.updateInteractiveTransition(percentComplete)
        
        println("updateInteractiveTransition, % = \(percentComplete)")
        
        let sourceViewTransform = CATransform3DMakeRotation(CubeAnimationController.Rotation * percentComplete, 0.0, 1.0, 0.0)
        let destinationViewTransform = CATransform3DMakeRotation(-CubeAnimationController.Rotation * percentComplete, 0.0, 1.0, 0.0)
        
        self.sourceView?.layer.transform = sourceViewTransform
        self.destinationView?.layer.transform = destinationViewTransform
        
//        if percentComplete >= 0.98 {
//            self.finishInteractiveTransition()
//        }
    }
    
    
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
        if let containerView = self.interactiveContainerView, sourceView = self.sourceView, destinationView = self.destinationView {
            self.resetScene(containerView, sourceView: sourceView, destinationView: destinationView)
        }
        
        self.sourceView?.layer.removeAllAnimations()
        self.destinationView?.layer.removeAllAnimations()
        
        self.interactivePopGestureRecognizer = nil
        self.interactive = false
        
        self.interactiveContainerView = nil
        self.sourceView = nil
        self.destinationView = nil
        println("CubeAnimationController - animationEnded")
    }


    //MARK: - UIViewControllerInteractiveTransitioning
    
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        println("CubeAnimationController - startInteractiveTransition")
        
        super.startInteractiveTransition(transitionContext)
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let sourceView = fromViewController.view
        let destinationView = toViewController.view
        let containerView = transitionContext.containerView()
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = containerView.bounds
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        self.setupScene(containerView, sourceView: sourceView, destinationView: destinationView)
        
        self.interactiveContainerView = containerView
        self.sourceView = fromViewController.view
        self.destinationView = toViewController.view
        self.startTouchPoint = self.interactivePopGestureRecognizer?.locationInView(self.interactiveContainerView)
    }
    
    
    //MARK: - Cube Animation
    
    
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
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        self.setupScene(containerView, sourceView: sourceView, destinationView: destinationView)
        
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
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        self.setupScene(containerView, sourceView: sourceView, destinationView: destinationView)
        
        // add animations
        let fromViewAnimation = self.createCubeTransformAnimation(CubeAnimationController.Rotation, view: sourceView, presenting: false)
        let toViewAnimation = self.createCubeTransformAnimation(-CubeAnimationController.Rotation, view: destinationView, presenting: true)
        toViewAnimation.completionBlock = { (success: Bool) -> Void in
            transitionContext.completeTransition(success)
        }
        
        sourceView.layer.addAnimation(fromViewAnimation, forKey: "fromViewCubeAnimation")
        destinationView.layer.addAnimation(toViewAnimation, forKey: "toViewCubeAnimation")
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
    
    
    func resetScene(containerView: UIView, sourceView: UIView, destinationView: UIView)
    {
        containerView.layer.sublayerTransform = CATransform3DIdentity
        
        sourceView.layer.transform = CATransform3DIdentity
        sourceView.layer.zPosition = 0
        sourceView.layer.anchorPointZ = 0
        
        destinationView.layer.transform = CATransform3DIdentity
        destinationView.layer.zPosition = 0
        destinationView.layer.anchorPointZ = 0
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
        
        return transformAnimation
    }
    
    
    func handleSwipe(gesture: UISwipeGestureRecognizer)
    {
        println("Swiping!!")
    }
}
