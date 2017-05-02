//
//  AARectLike.swift
//  AAGeometry
//

import AAFoundation
import CoreGraphics

public protocol AAMinMaxPointRanged {
    var minX: CGFloat { get }
    var minY: CGFloat { get }
    var maxX: CGFloat { get }
    var maxY: CGFloat { get }
}

public extension AAMinMaxPointRanged {
    public var midX: CGFloat { return (self.minX + self.maxX) / 2 }
    public var midY: CGFloat { return (self.minY + self.maxY) / 2 }
}
