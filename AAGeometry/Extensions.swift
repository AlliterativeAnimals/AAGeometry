//
//  Extensions.swift
//  AAGeometry
//

import CoreGraphics

extension CGRect: AAMinMaxPointRanged {}

public extension CGRect {
    public func edgeLine(along: CGRectEdge) -> AAUndirectedLine {
        switch along {
        case .maxXEdge:
            return AAUndirectedLine(point: self.pointMaxXMinY, anotherPoint: self.pointMaxXMaxY)
        case .minXEdge:
            return AAUndirectedLine(point: self.pointMinXMinY, anotherPoint: self.pointMinXMaxY)
        case .maxYEdge:
            return AAUndirectedLine(point: self.pointMinXMaxY, anotherPoint: self.pointMaxXMaxY)
        case .minYEdge:
            return AAUndirectedLine(point: self.pointMinXMinY, anotherPoint: self.pointMaxXMinY)
        }
    }
}
