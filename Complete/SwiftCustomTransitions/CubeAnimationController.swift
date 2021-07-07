//
//  CubeAnimationController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 4/5/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class CubeAnimationController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning, UIGestureRecognizerDelegate {
    
    // constants
    let Rotation: CGFloat = .pi / 2
    let Projection: CGFloat = 1 / -600
    let Duration: CFTimeInterval = 0.65
    
    // animation properties
    var reverseAnimation = false
    var transitionContext: UIViewControllerContextTransitioning?
    
    // interactive transition properties
    var interactive = false
    var startTouchPoint: CGPoint?
    var animationTimer: Timer?
    
    
    //MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval
    {
        return Duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)
    {
        self.transitionContext = transitionContext
        
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let (containerView, sourceView, destinationView) = transitionContextViews(transitionContext: transitionContext)
        
        // since the detail view was just built, it needs to be added to the view heirarchy
        containerView.addSubview(destinationView)
        destinationView.frame = transitionContext.finalFrame(for: toViewController)
        
        // setup the 3D scene by setting perspective in the container and configurin the view positions
        setupScene(containerView: containerView, sourceView: sourceView, destinationView: destinationView)
        
        // add animations
        var sourceViewAnimation: CABasicAnimation
        var destinationViewAnimation: CABasicAnimation
        
        if reverseAnimation {
            sourceViewAnimation = createCubeTransformAnimation(rotation: Rotation, view: sourceView, presenting: false)
            destinationViewAnimation = createCubeTransformAnimation(rotation: -Rotation, view: destinationView, presenting: true)
        }
        else {
            sourceViewAnimation = createCubeTransformAnimation(rotation: -Rotation, view: sourceView, presenting: false)
            destinationViewAnimation = createCubeTransformAnimation(rotation: Rotation, view: destinationView, presenting: true)
        }
        
        destinationViewAnimation.completionBlock = { (success: Bool) -> Void in
            // whenever this animation completes we need to update the context and determine
            // if the transition successfully completed.
            transitionContext.completeTransition(success && !transitionContext.transitionWasCancelled)
        }
        
        sourceView.layer.add(sourceViewAnimation, forKey: sourceViewAnimation.keyPath)
        destinationView.layer.add(destinationViewAnimation, forKey: destinationViewAnimation.keyPath)
    }
    
    
    func animationEnded(transitionCompleted: Bool)
    {
        transitionContext = nil
        interactive = false
        interactivePopGestureRecognizer = nil
    }


    //MARK: - UIViewControllerInteractiveTransitioning

    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning)
    {
        super.startInteractiveTransition(transitionContext)
        
        // the gesture has already began once this method fires, so we cannot rely on the Begin state for the
        // gesture to record the first touch point. instead, capture it here when the interactive transition begins.
        startTouchPoint = interactivePopGestureRecognizer?.location(in: transitionContext.containerView)
    }
    
    
    override func cancel() {
        super.cancel()
        
        // here we need to reset the layer properties for our views to their original values.
        // by doing this, we fix an animation flicker that shows the views in their final state
        let transitionContext = transitionContext!
        let (_, sourceView, destinationView) = transitionContextViews(transitionContext: transitionContext)
        
        let sourceViewAnimation = sourceView.layer.animation(forKey: "transform") as! CABasicAnimation
        let destinationViewAnimation = destinationView.layer.animation(forKey: "transform") as! CABasicAnimation
        
        sourceView.layer.transform = (sourceViewAnimation.fromValue as! NSValue).caTransform3DValue
        destinationView.layer.transform = (destinationViewAnimation.fromValue as! NSValue).caTransform3DValue
    }
    
    
    //MARK: - Gesture Recognizer
    // this gesture is owned by the UINavigationController and is used to update the transition
    // animation as the user pans across the screen. we become the delegate and respond to its
    // actions in order to use the gesture for the transition.
    var interactivePopGestureRecognizer: UIGestureRecognizer? {
        didSet {
            interactivePopGestureRecognizer?.delegate = self
            interactivePopGestureRecognizer?.addTarget(self, action: #selector(screenEdgeDidPan(gesture:)))
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // prevent the gesture from starting when we're in the middle of animating
        // to a new target value.
        if animationTimer != nil {
            return false
        }

        // this flag helps us determine when to tell the navigation controller when to use
        // this object as the interactive animation controller. we always want to handle
        // the animation as an interactive one when the pop gesture begins motion
        interactive = true

        return true
    }
    
    
    @objc func screenEdgeDidPan(gesture: UIGestureRecognizer)
    {
        if let transitionContext = transitionContext {
            
            let containerView = transitionContext.containerView
            let touchPoint = gesture.location(in: containerView)
            let progress = touchPoint.x / containerView.frame.width
            
            switch (gesture.state) {

            case .changed:
                self.update(progress)
                
                if progress >= 0.995 {
                    finish()
                }

            case .ended, .cancelled:
                
                // when a gesture ends, we need to determine how far through the user
                // was through the animation, and then advance our animation to either a 
                // fully transitioned or cancelled state. we control this with a custom
                // timer that updates the transition context until we reach the target progress
                if progress > 0.5 {
                    animateToPercentComplete(percent: 1)
                }
                else {
                    animateToPercentComplete(percent: 0)
                }

            default:
                break
            }
        }
    }
    
    
    //MARK: - Animation Timer
    
    func animateToPercentComplete(percent: CGFloat)
    {
        if animationTimer == nil {
            animationTimer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(adjustPercentComplete), userInfo: Float(percent), repeats: true)
        }
    }
    
    
    func stopAnimationTimer()
    {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    
    @objc func adjustPercentComplete(timer: Timer)
    {
        let targetPercent = timer.userInfo as! CGFloat
        let delta = (targetPercent - percentComplete) * 0.1
        
        update(percentComplete + delta)
        
        if abs(delta) < 0.0001 {
            
            self.stopAnimationTimer()
            
            if targetPercent == 1 {
                finish()
            }
            else {
                cancel()
            }
        }
    }
    
    
    //MARK: - Helpers
    
    // helper method to retrieve the contents of the transition context
    func transitionContextViews(transitionContext: UIViewControllerContextTransitioning) -> (containerView: UIView, sourceView: UIView, destinationView: UIView)
    {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        return (transitionContext.containerView, fromViewController.view, toViewController.view)
    }
    
    
    func setupScene(containerView: UIView, sourceView: UIView, destinationView: UIView)
    {
        // setup the 3D scene by setting perspective in the container and configuring the view positions
        // https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreAnimation_guide/AdvancedAnimationTricks/AdvancedAnimationTricks.html#//apple_ref/doc/uid/TP40004514-CH8-SW13
        var containerTransform = CATransform3DIdentity
        containerTransform.m34 = Projection
        containerView.layer.sublayerTransform = containerTransform
        
        // calculate the z-distance as a ratio of the width of the container. 
        // this keeps the edges of the cube sides aligned when rotating with different screen sizes
        let z = -(0.5 * transitionContext!.containerView.frame.width)
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
            transformAnimation.fromValue = NSValue(caTransform3D: viewFromTransform)
            transformAnimation.toValue = NSValue(caTransform3D: CATransform3DIdentity)
        }
        else {
            transformAnimation.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
            transformAnimation.toValue = NSValue(caTransform3D: viewFromTransform)
        }
        
        transformAnimation.duration = Duration
        
        // use a linear curve when interactive so the motion matches the movement of the touch
        if interactive {
            transformAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        }
        else {
            transformAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        }
        
        // set the view's layer to the final value. fixes flickering at the end of the animation
        view.layer.transform = (transformAnimation.toValue as! NSValue).caTransform3DValue
        
        return transformAnimation
    }
}
