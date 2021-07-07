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
        case image = "imageViewController"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.row) {
        case 0:
            
            let detailVC = storyboard!.instantiateViewController(withIdentifier: ViewControllerIdentifiers.detail.rawValue)
            detailVC.transitioningDelegate = self
            detailVC.modalPresentationStyle = UIModalPresentationStyle.custom
            present(detailVC, animated: true, completion: nil)

        case 1:
            
            let popupVC = storyboard!.instantiateViewController(withIdentifier: ViewControllerIdentifiers.popup.rawValue)
            present(popupVC, animated: true, completion: nil)

        case 2:
            
            let detailVC = storyboard!.instantiateViewController(withIdentifier: ViewControllerIdentifiers.cube.rawValue)
            detailVC.transitioningDelegate = self
            detailVC.modalPresentationStyle = UIModalPresentationStyle.custom
            navigationController?.delegate = self
            navigationController?.pushViewController(detailVC, animated: true)

        case 3:
            
            let imageVC = storyboard!.instantiateViewController(withIdentifier: ViewControllerIdentifiers.image.rawValue)
            imageVC.transitioningDelegate = self
            imageVC.modalPresentationStyle = UIModalPresentationStyle.custom
            present(imageVC, animated: true, completion: nil)

        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - <UIViewControllerTransitioningDelegate>
    
    lazy var zoomAnimation = ZoomAnimationController()
    lazy var cubeAnimation = CubeAnimationController()
    lazy var imageAnimation = ImageAnimationController()

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is DetailViewController {
            zoomAnimation.reverseAnimation = false
            return zoomAnimation
        }
        else if presented is ImageViewController {
            imageAnimation.reverseAnimation = false
            return imageAnimation
        }
        return nil
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed is DetailViewController {
            zoomAnimation.reverseAnimation = true
            return zoomAnimation
        }
        else if dismissed is ImageViewController {
            imageAnimation.reverseAnimation = true
            return imageAnimation
        }
        return nil
    }

    
    //MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        switch (operation) {
        case .pop:
            cubeAnimation.reverseAnimation = true

        default:
            cubeAnimation.reverseAnimation = false
        }
        
        cubeAnimation.interactivePopGestureRecognizer = navigationController.interactivePopGestureRecognizer
        
        return cubeAnimation
    }

    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if cubeAnimation.interactive {
            return cubeAnimation
        }
        return nil
    }
}
