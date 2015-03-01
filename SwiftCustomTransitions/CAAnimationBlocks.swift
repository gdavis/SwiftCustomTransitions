//
//  CAAnimationBlocks.swift
//  SwiftCustomTransitions
//
//  Created by Grant Davis on 3/1/15.
//  Copyright (c) 2015 Grant Davis Interactive, LLC. All rights reserved.
//

import UIKit

extension CAAnimation {
    
    typealias StartBlock = ((Void) -> Void)
    typealias CompletionBlock = ((finished: Bool) -> Void)
    
    private struct Blocks {
        static var startBlocks: [CAAnimation: StartBlock] = Dictionary<CAAnimation, StartBlock>()
        static var completionBlocks: [CAAnimation: CompletionBlock] = Dictionary<CAAnimation, CompletionBlock>()
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
    
    
    public override func animationDidStart(anim: CAAnimation!)
    {
        if let block = self.startBlock {
            block()
            Blocks.startBlocks.removeValueForKey(self)
        }
    }
    
    
    public override func animationDidStop(anim: CAAnimation!, finished flag: Bool)
    {
        if let block = self.completionBlock {
            block(finished: flag)
            Blocks.completionBlocks.removeValueForKey(self)
        }
    }
}