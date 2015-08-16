//
//  TransitionsTableView.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 2/27/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class TransitionsTableView: UITableViewController
{
    private enum ViewControllerIdentifiers : String
    {
        case detail = "detailViewController"
        case popup = "popupViewController"
        case cube = "cubeDetailViewController"
        case image = "imageViewController"
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch (indexPath.row) {
        case 0:
            
            let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.detail.rawValue) as! UIViewController
            self.presentViewController(detailVC, animated: true, completion: nil)
            break
            
        case 1:
            
            let popupVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.popup.rawValue) as! UIViewController
            self.presentViewController(popupVC, animated: true, completion: nil)
            break
        
        case 2:
            
            let detailVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.cube.rawValue) as! UIViewController
            self.navigationController?.pushViewController(detailVC, animated: true)
            break
            
        case 3:
            
            let imageVC = self.storyboard!.instantiateViewControllerWithIdentifier(ViewControllerIdentifiers.image.rawValue) as! UIViewController
            self.presentViewController(imageVC, animated: true, completion: nil)
            break
            
        default:
            break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
