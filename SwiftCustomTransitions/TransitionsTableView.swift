//
//  TransitionsTableView.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/27/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class TransitionsTableView: UITableViewController, UIViewControllerTransitioningDelegate
{
    internal enum ViewControllerIdentifiers : String {
        case detail = "detailViewController"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.row) {
        case 0:
            
            let detailVC = self.storyboard?.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.detail.rawValue) as! DetailViewController
            detailVC.transitioningDelegate = self
            detailVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            
            self.presentViewController(detailVC, animated: true, completion: nil)
            break
            
        default:
            break
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return ZoomAnimation(isReverseAnimation: false)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return ZoomAnimation(isReverseAnimation: true)
    }
}
