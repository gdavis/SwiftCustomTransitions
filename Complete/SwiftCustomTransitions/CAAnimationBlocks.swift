//
//  CAAnimationBlocks.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 3/1/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

extension CAAnimation {
    
    typealias StartBlock = (() -> Void)
    typealias CompletionBlock = ((_ finished: Bool) -> Void)
    
    private struct Blocks {
        static var startBlocks = Dictionary<CAAnimation, StartBlock>()
        static var completionBlocks = Dictionary<CAAnimation, CompletionBlock>()
    }
    
    var startBlock: StartBlock? {
        get {
            return Blocks.startBlocks[self]
        }
        set {
            Blocks.startBlocks[self] = newValue
            self.delegate = self
        }
    }
    
    var completionBlock: CompletionBlock? {
        get {
            return Blocks.completionBlocks[self]
        }
        set {
            Blocks.completionBlocks[self] = newValue
            self.delegate = self
        }
    }
}

extension CAAnimation: CAAnimationDelegate {
    public func animationDidStart(_ anim: CAAnimation) {
        if let block = self.startBlock {
            block()
            Blocks.startBlocks.removeValue(forKey: self)
            Blocks.startBlocks.removeValue(forKey: self)
        }
    }

    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let block = self.completionBlock {
            block(flag)
            Blocks.completionBlocks.removeValue(forKey: self)
        }
    }
}
