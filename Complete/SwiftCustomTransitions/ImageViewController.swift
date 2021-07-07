//
//  ImageViewController.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 8/14/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var quoteLabel: UILabel!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        quoteLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3, animations: { [unowned self] in
            self.quoteLabel.alpha = 1
        })
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15, animations: { [unowned self] in
            self.quoteLabel.alpha = 0
            }) { [unowned self] (finished: Bool) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
    }
}
