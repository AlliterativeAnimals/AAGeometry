//
//  LPRectLike.swift
//  Line Puzzle
//
//  Created by David Godfrey on 07/02/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import AAFoundation
import CoreGraphics

public protocol LPMinMaxPointRanged {
    var minX: CGFloat { get }
    var minY: CGFloat { get }
    var maxX: CGFloat { get }
    var maxY: CGFloat { get }
}

public extension LPMinMaxPointRanged {
    public var midX: CGFloat { return (self.minX + self.maxX) / 2 }
    public var midY: CGFloat { return (self.minY + self.maxY) / 2 }
}
