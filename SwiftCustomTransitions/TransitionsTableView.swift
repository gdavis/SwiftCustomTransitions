//
//  TransitionsTableView.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/27/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class TransitionsTableView: UITableViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate
{
    private enum ViewControllerIdentifiers : String
    {
        case detail = "detailViewController"
        case popup = "popupViewController"
        case cube = "cubeDetailViewController"
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch (indexPath.row) {
        case 0:
            
            let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.detail.rawValue) as! UIViewController
            detailVC.transitioningDelegate = self
            detailVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            self.presentViewController(detailVC, animated: true, completion: nil)
            
            break
            
        case 1:
            
            let popupVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.popup.rawValue) as! UIViewController
            popupVC.transitioningDelegate = self
            popupVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            self.presentViewController(popupVC, animated: true, completion: nil)
            
            break
        
        case 2:
            
            let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.cube.rawValue) as! UIViewController
            detailVC.transitioningDelegate = self
            detailVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            self.navigationController?.delegate = self
            self.navigationController?.pushViewController(detailVC, animated: true)
            
            break
            
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //MARK: - <UIViewControllerTransitioningDelegate>
    
    lazy var zoomAnimation = ZoomAnimationController()
    lazy var popupAnimation = PopupAnimationController()
    lazy var cubeAnimation = CubeAnimationController()
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        println("animationControllerForPresentedController")
        
        if presented.isKindOfClass(DetailViewController) {
            self.zoomAnimation.reverseAnimation = false
            return self.zoomAnimation
        }
        else if presented.isKindOfClass(PopupViewController) {
            self.popupAnimation.reverseAnimation = false
            return self.popupAnimation
        }
//        else if presented.isKindOfClass(CubeDetailViewController) {
//            self.cubeAnimation.reverseAnimation = false
//            return self.cubeAnimation
//        }
        return nil
    }
    
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        println("animationControllerForDismissedController")
        
        if dismissed.isKindOfClass(DetailViewController) {
            self.zoomAnimation.reverseAnimation = true
            return self.zoomAnimation
        }
        else if dismissed.isKindOfClass(PopupViewController) {
            self.popupAnimation.reverseAnimation = true
            return self.popupAnimation
        }
//        else if dismissed.isKindOfClass(CubeDetailViewController) {
//            self.cubeAnimation.reverseAnimation = true
//            return self.cubeAnimation
//        }
        return nil
    }
    
//    // note: these are called after the methods above
//    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
//    {
//        println("interactionControllerForPresentation")
//        if animator.isKindOfClass(CubeAnimationController) {
//            return animator as! CubeAnimationController
//        }
//        
//        return nil
//    }
//    
//    
//    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
//    {
//        println("interactionControllerForDismissal")
//        if animator.isKindOfClass(CubeAnimationController) {
//            return animator as! CubeAnimationController
//        }
//        
//        return nil
//    }
    
    
    //MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        switch (operation) {

        case .Pop:
            self.cubeAnimation.reverseAnimation = true
            break
            
        default:
            self.cubeAnimation.reverseAnimation = false
            break
        }
        
        self.cubeAnimation.interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer
        
        return self.cubeAnimation
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning?
    {
        if self.cubeAnimation.interactive {
            return self.cubeAnimation
        }
        return nil
    }
}
