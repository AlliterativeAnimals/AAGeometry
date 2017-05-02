//
//  Extensions.swift
//  AAGeometry
//
//  Created by David Godfrey on 02/05/2017.
//  Copyright © 2017 Alliterative Animals. All rights reserved.
//

import CoreGraphics

extension CGRect: LPMinMaxPointRanged {}

public extension CGRect {
    public func edgeLine(along: CGRectEdge) -> LPUndirectedLine {
        switch along {
        case .maxXEdge:
            return LPUndirectedLine(point: self.pointMaxXMinY, anotherPoint: self.pointMaxXMaxY)
        case .minXEdge:
            return LPUndirectedLine(point: self.pointMinXMinY, anotherPoint: self.pointMinXMaxY)
        case .maxYEdge:
            return LPUndirectedLine(point: self.pointMinXMaxY, anotherPoint: self.pointMaxXMaxY)
        case .minYEdge:
            return LPUndirectedLine(point: self.pointMinXMinY, anotherPoint: self.pointMaxXMinY)
        }
    }
}
