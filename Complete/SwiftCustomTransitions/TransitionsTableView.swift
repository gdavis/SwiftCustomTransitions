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
        case space = "spaceViewController"
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
            self.presentViewController(popupVC, animated: true, completion: nil)
            
            break
        
        case 2:
            
            let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.cube.rawValue) as! UIViewController
            detailVC.transitioningDelegate = self
            detailVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            self.navigationController?.delegate = self
            self.navigationController?.pushViewController(detailVC, animated: true)
            
            break
            
        case 3:
            
            let spaceVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.space.rawValue) as! UIViewController
            spaceVC.transitioningDelegate = self
            spaceVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            self.presentViewController(spaceVC, animated: true, completion: nil)
            break
            
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    //MARK: - <UIViewControllerTransitioningDelegate>
    
    lazy var zoomAnimation = ZoomAnimationController()
    lazy var cubeAnimation = CubeAnimationController()
    lazy var spaceAnimation = SpaceAnimationController()
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if presented.isKindOfClass(DetailViewController) {
            self.zoomAnimation.reverseAnimation = false
            return self.zoomAnimation
        }
        else if presented.isKindOfClass(SpaceViewController) {
            self.spaceAnimation.reverseAnimation = false
            return self.spaceAnimation
        }
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        if dismissed.isKindOfClass(DetailViewController) {
            self.zoomAnimation.reverseAnimation = true
            return self.zoomAnimation
        }
        else if dismissed.isKindOfClass(SpaceViewController) {
            self.spaceAnimation.reverseAnimation = true
            return self.spaceAnimation
        }
        return nil
    }

    
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
